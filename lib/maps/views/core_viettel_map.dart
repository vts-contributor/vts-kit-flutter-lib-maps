import 'package:flutter/cupertino.dart';
import 'package:maps_core/maps/extensions/convert.dart';
import 'package:maps_core/maps/controllers/implementations/viettel_map_controller.dart';
import 'package:maps_core/maps/models/core_map_callbacks.dart';

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

  /// just to make sure if onStyleLoadedCallback may be called first (may never happen)
  bool onStyleLoadedWasCalled = false;

  @override
  Widget build(BuildContext context) {
    return vt.VTMap(
      accessToken: widget.data.accessToken,
      initialCameraPosition: widget.data.initialCameraPosition.toViettel(),
      onStyleLoadedCallback: () {
        onStyleLoadedWasCalled = true;

        _controller?.onStyleLoaded();

        if (_controller != null) {
          //use '!' instead of 'late' because this is less error-prone
          widget.callbacks?.onMapCreated?.call(_controller!);
        }
      },
      onMapCreated: (vt.MapboxMapController mapboxMapController) {
        final controller = ViettelMapController(mapboxMapController,
            data: widget.data,
            callback: widget.callbacks
        );

        _controller = controller;

        //don't call onMapCreated from callbacks here because map is not ready yet
        //use onStyleLoadedCallback to be synchronized with GoogleMap
        //but just to make sure controller will be returned
        if (onStyleLoadedWasCalled) {
          widget.callbacks?.onMapCreated?.call(controller);
        }
      },
    );
  }

  void _tryReturnController() {

  }
}
