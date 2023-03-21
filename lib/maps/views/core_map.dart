import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:maps_core/maps/models/core_map_callbacks.dart';
import 'package:maps_core/maps/views/core_google_map.dart';
import 'package:maps_core/maps/views/core_viettel_map.dart';

import '../models/core_map_data.dart';
import '../models/core_map_type.dart';

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

  late CoreMapData _data;
  late CoreMapType _type;

  @override
  void initState() {
    super.initState();

    _data = widget.initialData;
    _type = widget.initialType;
  }

  @override
  Widget build(BuildContext context) {
    return buildMap(_type, _data,
      callbacks: _internalCallbacks
    );
  }

  Widget buildMap(CoreMapType type, CoreMapData data, {
    CoreMapCallbacks? callbacks,
  }) {
    switch (type) {
      case CoreMapType.google:
        return CoreGoogleMap(
          data: data,
          callbacks: callbacks,
        );
      case CoreMapType.viettel:
        return CoreViettelMap(
          data: data,
          callbacks: callbacks,
        );
    }
  }

  ///Modify user's callback for internal use
  CoreMapCallbacks get _internalCallbacks {
    final callbacks = widget.callbacks ?? CoreMapCallbacks();

    return callbacks.copyWith(
      onChangeMapType: (data, oldType, newType) {
        setState(() {
          _data = data;
          _type = newType;
        });

        widget.callbacks?.onChangeMapType?.call(data, oldType, newType);
      }
    );
  }
}

