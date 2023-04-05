import 'package:flutter/cupertino.dart';
import 'package:maps_core/maps.dart';
import 'package:maps_core/maps/extensions/model_convert.dart';
import 'package:maps_core/maps/controllers/implementations/viettel_map_controller.dart';
import 'package:maps_core/maps/models/core_map_callbacks.dart';
import 'package:maps_core/maps/models/map_objects/marker_icon_data_factory.dart';

import '../../log/log.dart';
import '../models/core_map_data.dart';

import 'package:vtmap_gl/vtmap_gl.dart' as vt;

class CoreViettelMap extends StatefulWidget {
  final CoreMapData data;
  final CoreMapCallbacks? callbacks;
  final CoreMapShapes shapes;
  const CoreViettelMap({Key? key,
    required this.data,
    this.callbacks,
    required this.shapes,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CoreViettelMapState();
}

class _CoreViettelMapState extends State<CoreViettelMap> {

  ViettelMapController? _controller;

  final MarkerIconDataFactory _markerIconDataFactory = MarkerIconDataFactory();

  @override
  void didUpdateWidget(covariant CoreViettelMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    _updateCallbacks();

    _updateShapes();
  }

  void _updateCallbacks() {
    _controller?.callbacks = widget.callbacks;
  }

  void _updateShapes() {
    _controller?.loadNewShapes(widget.shapes);
  }

  @override
  Widget build(BuildContext context) {

    CoreMapData data = widget.data;
    
    return vt.VTMap(
      accessToken: data.accessToken,
      initialCameraPosition: data.initialCameraPosition.toViettel(),
      onStyleLoadedCallback: () {
        _controller?.onStyleLoaded(widget.shapes);
      },
      minMaxZoomPreference: data.minMaxZoomPreference.toViettel(),
      cameraTargetBounds: data.cameraTargetBounds.toViettel(),
      compassEnabled: data.compassEnabled,
      rotateGesturesEnabled: data.rotateGesturesEnabled,
      scrollGesturesEnabled: data.scrollGesturesEnabled,
      zoomGesturesEnabled: data.zoomGesturesEnabled,
      tiltGesturesEnabled: data.tiltGesturesEnabled,
      myLocationEnabled: data.myLocationEnabled,

      compassViewPosition: vt.CompassViewPosition.TopLeft,

      onMapCreated: (vt.MapboxMapController mapboxMapController) {
        final controller = ViettelMapController(mapboxMapController,
          data: data,
          callbacks: widget.callbacks,
          markerIconDataProcessor: _markerIconDataFactory
        );

        _controller = controller;

        //return the controller back to user in onStyleLoaded()
      },
      trackCameraPosition: true,
      onCameraMovingStarted: () {
        _controller?.onCameraMovingStarted();
      },
      onCameraIdle: () {
        _controller?.onCameraIdle();
      },
      onMapClick: (point, coordinate) {
        if (coordinate != null) {
          _controller?.onMapClick(coordinate);
        }
      },
      onMapLongClick: (point, coordinate) {
        if (coordinate != null) {
          _controller?.onMapLongClick(coordinate);
        }
      },
    );
  }
}
