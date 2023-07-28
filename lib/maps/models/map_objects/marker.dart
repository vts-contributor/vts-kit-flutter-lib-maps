// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' show Offset;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'
    show immutable, ValueChanged, VoidCallback;
import 'package:maps_core/maps/extensions/convert.dart';
import 'package:maps_core/maps/models/map_objects/map_object.dart';

import 'lat_lng.dart';
import 'marker_icon.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as ggmap;
import 'package:vtmap_gl/vtmap_gl.dart' as vtmap;

Object _offsetToJson(Offset offset) {
  return <Object>[offset.dx, offset.dy];
}

/// Text labels for a [Marker] info window.
@immutable
class InfoWindow {
  /// Creates an immutable representation of a label on for [Marker].
  const InfoWindow({
    required this.widget,
    this.maxSize = const Size(400, 400),
    this.bottomOffset = 4
  });

  ///widget to be displayed
  final Widget widget;

  ///max possible size
  final Size maxSize;

  ///distance between info window and marker's icon
  final double bottomOffset;

  // /// The icon image point that will be the anchor of the info window when
  // /// displayed.
  // ///
  // /// The image point is specified in normalized coordinates: An anchor of
  // /// (0.0, 0.0) means the top left corner of the image. An anchor
  // /// of (1.0, 1.0) means the bottom right corner of the image.
  // final Anchor anchor;

  /// Creates a new [InfoWindow] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  InfoWindow copyWith({
    Widget? widgetParam,
    Size? maxSizeParam,
    double? bottomOffsetParam,
  }) {
    return InfoWindow(
      widget: widgetParam ?? widget,
      maxSize: maxSizeParam ?? maxSize,
      bottomOffset: bottomOffsetParam ?? bottomOffset,
    );
  }


  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is InfoWindow &&
        other.widget.key == widget.key &&
        other.bottomOffset == bottomOffset &&
        maxSize == other.maxSize;
  }

  @override
  int get hashCode => Object.hash(widget.hashCode, maxSize);
}

enum Anchor {
  center,
  top,
  bottom,
  left,
  right,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight;

  Offset get offset {
    switch(this) {
      case Anchor.center:
        return const Offset(0.5, 0.5);
      case Anchor.top:
        return const Offset(0.5, 0);
      case Anchor.bottom:
        return const Offset(0.5, 1);
      case Anchor.left:
        return const Offset(0, 0.5);
      case Anchor.right:
        return const Offset(1, 0.5);
      case Anchor.topLeft:
        return const Offset(0, 0);
      case Anchor.topRight:
        return const Offset(1, 0);
      case Anchor.bottomLeft:
        return const Offset(0, 1);
      case Anchor.bottomRight:
        return const Offset(1, 1);
    }
  }

  String get string {
    switch(this) {
      case Anchor.center:
        return "center";
      case Anchor.top:
        return "top";
      case Anchor.bottom:
        return "bottom";
      case Anchor.left:
        return "left";
      case Anchor.right:
        return "right";
      case Anchor.topLeft:
        return "top-left";
      case Anchor.topRight:
        return "top-right";
      case Anchor.bottomLeft:
        return "bottom-left";
      case Anchor.bottomRight:
        return "bottom-right";
    }
  }
}

/// Uniquely identifies a [Marker] among [CoreMap] markers.
///
/// This does not have to be globally unique, only unique among the list.
@immutable
class MarkerId extends MapObjectId<Marker> {
  /// Creates an immutable identifier for a [Marker].
  const MarkerId(String value) : super(value);
}

/// Marks a geographical location on the map.
///
/// A marker icon is drawn oriented against the device's screen rather than
/// the map's surface; that is, it will not necessarily change orientation
/// due to map rotations, tilting, or zooming.
@immutable
class Marker implements MapObject<Marker> {
  /// Creates a set of marker configuration options.
  ///
  /// Default marker options.
  ///
  /// Specifies a marker that
  /// * is fully opaque; [alpha] is 1.0
  /// * uses icon bottom center to indicate map position; [anchor] is (0.5, 1.0)
  /// * has default tap handling; [consumeTapEvents] is false
  /// * is stationary; [draggable] is false
  /// * is drawn against the screen, not the map; [flat] is false
  /// * has a default icon; [icon] is `BitmapDescriptor.defaultMarker`
  /// * anchors the info window at top center; [infoWindowAnchor] is (0.5, 0.0)
  /// * has no info window text; [infoWindowText] is `InfoWindowText.noText`
  /// * is positioned at 0, 0; [position] is `LatLng(0.0, 0.0)`
  /// * has an axis-aligned icon; [rotation] is 0.0
  /// * is visible; [visible] is true
  /// * is placed at the base of the drawing order; [zIndex] is 0.0
  /// * reports [onTap] events
  /// * reports [onDragEnd] events
  const Marker({
    required this.id,
    this.alpha = 1.0,
    this.anchor = Anchor.bottom,
    this.draggable = false,
    this.flat = false,
    this.icon = MarkerIcon.defaultIcon,
    this.infoWindow,
    required this.position,
    this.rotation = 0.0,
    this.visible = true,
    this.zIndex = 0,
    this.onTap,
    this.onDrag,
    this.onDragStart,
    this.onDragEnd,
  }) : assert((0.0 <= alpha && alpha <= 1.0));

  /// Uniquely identifies a [Marker].
  @override
  final MarkerId id;

  /// The opacity of the marker, between 0.0 and 1.0 inclusive.
  ///
  /// 0.0 means fully transparent, 1.0 means fully opaque.
  final double alpha;

  /// The icon image point that will be placed at the [position] of the marker.
  final Anchor anchor;


  /// True if the marker is draggable by user touch events.
  final bool draggable;

  /// True if the marker is rendered flatly against the surface of the Earth, so
  /// that it will rotate and tilt along with map camera movements.
  final bool flat;

  /// A description of the bitmap used to draw the marker icon.
  final MarkerIcon icon;

  /// A Google Maps InfoWindow.
  ///
  /// The window is displayed when the marker is tapped.
  final InfoWindow? infoWindow;

  /// Geographical location of the marker.
  final LatLng position;

  /// Rotation of the marker image in degrees clockwise from the [anchor] point.
  final double rotation;

  /// True if the marker is visible.
  final bool visible;

  /// The z-index of the marker, used to determine relative drawing order of
  /// map overlays.
  ///
  /// Overlays are drawn in order of z-index, so that lower values means drawn
  /// earlier, and thus appearing to be closer to the surface of the Earth.
  @override
  final int zIndex;

  /// Callbacks to receive tap events for markers placed on this map.
  final VoidCallback? onTap;

  /// Signature reporting the new [LatLng] at the start of a drag event.
  final ValueChanged<LatLng>? onDragStart;

  /// Signature reporting the new [LatLng] at the end of a drag event.
  final ValueChanged<LatLng>? onDragEnd;

  /// Signature reporting the new [LatLng] during the drag event.
  final ValueChanged<LatLng>? onDrag;

  /// Creates a new [Marker] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  Marker copyWith({
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
  }) {
    return Marker(
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
    );
  }

  /// Creates a new [Marker] object whose values are the same as this instance.
  Marker clone() => copyWith();

  /// Converts this object to something serializable in JSON.
  Object toJson() {
    final Map<String, Object> json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('markerId', id);
    addIfPresent('alpha', alpha);
    addIfPresent('anchor', _offsetToJson(anchor.offset));
    addIfPresent('draggable', draggable);
    addIfPresent('flat', flat);
    addIfPresent('icon', icon);
    addIfPresent('position', position.toJson());
    addIfPresent('rotation', rotation);
    addIfPresent('visible', visible);
    addIfPresent('zIndex', zIndex);
    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Marker &&
        id == other.id &&
        alpha == other.alpha &&
        anchor == other.anchor &&
        draggable == other.draggable &&
        flat == other.flat &&
        icon == other.icon &&
        infoWindow == other.infoWindow &&
        position == other.position &&
        rotation == other.rotation &&
        visible == other.visible &&
        zIndex == other.zIndex;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Marker{markerId: $id, alpha: $alpha, anchor: $anchor, '
        'icon: $icon, infoWindow: $infoWindow, position: $position, rotation: $rotation, '
        'visible: $visible, zIndex: $zIndex, onTap: $onTap, onDragStart: $onDragStart, '
        'onDrag: $onDrag, onDragEnd: $onDragEnd}';
  }

  ggmap.Marker toGoogle(Uint8List markerBitmap) {
    ggmap.BitmapDescriptor markerDescriptor;

    markerDescriptor = ggmap.BitmapDescriptor.fromBytes(markerBitmap);

    return ggmap.Marker(
      markerId: ggmap.MarkerId(id.value),
      alpha: alpha,
      anchor: anchor.offset,
      consumeTapEvents: onTap != null,
      draggable: draggable,
      flat: flat,
      icon: markerDescriptor,
      position: position.toGoogle(),
      rotation: rotation,
      visible: visible,
      zIndex: zIndex.toDouble(),
      onTap: onTap,
      onDrag: (ggmap.LatLng value) => onDrag?.call(value.toCore()),
      onDragStart: (ggmap.LatLng value) => onDragStart?.call(value.toCore()),
      onDragEnd: (ggmap.LatLng value) => onDragEnd?.call(value.toCore()),
    );
  }

  vtmap.SymbolOptions toSymbolOptions() {
    return vtmap.SymbolOptions(
      geometry: position.toViettel(),
      iconImage: icon.data.name,
      iconOpacity: alpha,
      iconAnchor: anchor.string,
      // draggable: true,
      zIndex: zIndex.toInt(),
      // fontNames: ["Arial Unicode MS Regular"],
      // textField: 'Airport',
      // textSize: 500,
      // textOffset: Offset(0, 0.8),
      // textAnchor: 'top',
      // textColor: '#000000',
      // textHaloBlur: 1,
      // textHaloColor: '#ffffff',
      // textHaloWidth: 0.8,
    );
  }
}
