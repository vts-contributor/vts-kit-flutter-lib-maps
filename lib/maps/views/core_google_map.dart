import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gg;
import 'package:maps_core/maps/controllers/implementations/google_map_controller.dart';
import 'package:maps_core/maps/extensions/extensions.dart';
import 'package:maps_core/maps/models/core_map_callbacks.dart';

import '../models/core_map_data.dart';

class CoreGoogleMap extends StatefulWidget {

  final CoreMapData data;
  final CoreMapCallbacks? callbacks;

  const CoreGoogleMap({Key? key,
    required this.data,
    this.callbacks
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CoreGoogleMapState();
}

class _CoreGoogleMapState extends State<CoreGoogleMap> {

  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {

    CoreMapData data = _controller?.data ?? widget.data;

    return gg.GoogleMap(
      initialCameraPosition: data.initialCameraPosition.toGoogle(),
      onMapCreated: (gg.GoogleMapController googleMapController) {
        //reminder: check leak here, may happen because of passing method?
        final controller = GoogleMapController(googleMapController,
          data: data,
          callback: widget.callbacks,
        );

        controller.addListener(() => setState(() {}));

        _controller = controller;
        widget.callbacks?.onMapCreated?.call(controller);
      },
      polygons: data.polygons.toGoogle().toSet(),
      polylines: data.polylines.toGoogle().toSet(),
    );
  }

}


