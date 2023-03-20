import 'package:flutter/cupertino.dart';
import 'package:maps_core/maps/models/core_map_callbacks.dart';
import 'package:maps_core/maps/views/google_map_wrapper.dart';
import 'package:maps_core/maps/views/viettel_map_wrapper.dart';

import '../models/core_map_data.dart';
import '../models/core_map_type.dart';

///**Act as a view factory for maps**
///
///This widget is stateless so that you can use your own state management.
///
class CoreMap extends StatelessWidget {
  final CoreMapType type;
  final CoreMapData data;
  final CoreMapCallbacks? callbacks;
  const CoreMap({super.key,
    this.type = CoreMapType.viettel,
    this.callbacks,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case CoreMapType.google:
        return GoogleMapWrapper(
          data: data,
          callbacks: callbacks,
        );
      case CoreMapType.viettel:
        return ViettelMapWrapper(
          data: data,
          callbacks: callbacks,
        );
    }
  }
}

