import 'package:flutter/cupertino.dart';
import 'package:maps_core/maps/extensions/convert.dart';
import 'package:maps_core/maps/controllers/implementations/viettel_map_controller.dart';
import 'package:maps_core/maps/models/core_map_callbacks.dart';

import '../../log/log.dart';
import '../models/core_map_data.dart';

import 'package:vtmap_gl/vtmap_gl.dart' as vt;

class CoreViettelMap extends StatefulWidget {
  final CoreMapData data;
  final CoreMapCallbacks? callbacks;
  const CoreViettelMap({Key? key,
    required this.data,
    this.callbacks
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CoreViettelMapState();
}

class _CoreViettelMapState extends State<CoreViettelMap> {

  ViettelMapController? _controller;

  @override
  Widget build(BuildContext context) {
    return vt.VTMap(
      accessToken: widget.data.accessToken,
      initialCameraPosition: widget.data.initialCameraPosition.toViettel(),
      onStyleLoadedCallback: () {
        _controller?.onStyleLoaded();
      },
      onMapCreated: (vt.MapboxMapController mapboxMapController) {
        final controller = ViettelMapController(mapboxMapController,
            data: widget.data,
            callback: widget.callbacks
        );

        _controller = controller;

        //return the controller back to user in onStyleLoaded()
      },
      trackCameraPosition: widget.callbacks?.onCameraMove != null,
      myLocationTrackingMode: vt.MyLocationTrackingMode.None,
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
