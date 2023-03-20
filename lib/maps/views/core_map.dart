import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:maps_core/maps/controllers/core_map_controller.dart';
import 'package:maps_core/maps/models/core_map_callbacks.dart';
import 'package:maps_core/maps/views/google_map_wrapper.dart';
import 'package:maps_core/maps/views/viettel_map_wrapper.dart';

import '../models/core_map_data.dart';
import '../models/core_map_type.dart';

///**Act as a view factory for maps**
///
///This widget is stateless so that you can use your own state management.
///
class CoreMap extends StatefulWidget {
  final CoreMapType initialType;
  final CoreMapData initialData;
  final CoreMapCallbacks? callbacks;
  const CoreMap({super.key,
    this.initialType = CoreMapType.viettel,
    this.callbacks,
    required this.initialData,
  });

  @override
  State<StatefulWidget> createState() => _CoreMapState();

}

class _CoreMapState extends State<CoreMap> {

  Completer<CoreMapController> _controllerCompleter = Completer();

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return buildMap(widget.initialType, widget.initialData,
      callbacks: widget.callbacks
    );
  }

  Widget buildMap(CoreMapType type, CoreMapData data, {
    CoreMapCallbacks? callbacks
  }) {
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

