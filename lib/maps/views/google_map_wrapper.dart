import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gg;
import 'package:maps_core/maps/controllers/google_map_controller.dart';
import 'package:maps_core/maps/models/core_map_callbacks.dart';
import 'package:maps_core/maps/models/extensions/convert_extensions.dart';
import 'package:maps_core/maps/models/extensions/list_convert_extensions.dart';

import '../models/core_map_data.dart';

class GoogleMapWrapper extends StatelessWidget {

  final CoreMapData data;
  final CoreMapCallbacks? callbacks;

  const GoogleMapWrapper({Key? key,
    required this.data,
    this.callbacks
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return gg.GoogleMap(
      initialCameraPosition: data.initialCameraPosition.toGoogle(),
      onMapCreated: (gg.GoogleMapController googleMapController) {
        //reminder: check leak here, may happen because of passing method?
        final controller = GoogleMapController(googleMapController,
          data: data,
        );

        callbacks?.onMapCreated?.call(controller);
      },
      polygons: data.polygons.toGoogle().toSet(),
    );
  }

}


