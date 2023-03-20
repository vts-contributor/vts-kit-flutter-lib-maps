import 'package:flutter/cupertino.dart';
import 'package:maps_core/maps/controllers/viettel_map_controller.dart';
import 'package:maps_core/maps/models/core_map_callbacks.dart';
import 'package:maps_core/maps/models/extensions/convert_extensions.dart';

import '../models/core_map_data.dart';

import 'package:vtmap_gl/vtmap_gl.dart' as vt;

class ViettelMapWrapper extends StatelessWidget {
  final CoreMapData data;
  final CoreMapCallbacks? callbacks;
  const ViettelMapWrapper({Key? key,
    required this.data,
    this.callbacks
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return vt.VTMap(
      accessToken: data.accessToken,
      initialCameraPosition: data.initialCameraPosition.toViettel(),
      onMapCreated: (vt.MapboxMapController mapboxMapController) {
        final controller = VTMapController(mapboxMapController,
          data: data
        );

        //return for user
        callbacks?.onMapCreated?.call(controller);
      },
    );
  }
}
