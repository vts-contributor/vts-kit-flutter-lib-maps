import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:maps_core/log/log.dart';

import 'package:maps_core/maps.dart';
import 'package:maps_core/maps/views/managers/routing_manager.dart';
import 'package:vtmap_gl/vtmap_gl.dart' as vt;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gg;
import 'package:rxdart/rxdart.dart';

import '../controllers/implementations/google_map_controller.dart';
import '../controllers/implementations/viettel_map_controller.dart';
import '../models/map_objects/marker_icon_data_factory.dart';

part 'managers/location_manager.dart';
part 'managers/routing_manager_impl.dart';
part 'core_viettel_map.dart';
part 'core_google_map.dart';

class CoreMap extends StatefulWidget {

  final CoreMapType type;

  final CoreMapData data;

  final CoreMapShapes? shapes;

  final CoreMapCallbacks? callbacks;

  const CoreMap({super.key,
    this.type = CoreMapType.viettel,
    this.callbacks,
    required this.data,
    this.shapes,
  });

  @override
  State<CoreMap> createState() => _CoreMapState();
}

class _CoreMapState extends State<CoreMap> with WidgetsBindingObserver {

  CoreMapController? _controller;

  late final _LocationManager _locationManager = _LocationManager(widget.callbacks);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initLocationManager();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _initLocationManager() {
    _locationManager.addListener(() {
      setState(() {});
    });

    _locationManager.enabled = widget.data.myLocationEnabled;
  }

  @override
  void didUpdateWidget(covariant CoreMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    _locationManager.updateCallbacks(widget.callbacks);
    _locationManager.enabled = widget.data.myLocationEnabled;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _locationManager.updateOnWidgetResumed();
    }
  }


  @override
  Widget build(BuildContext context) {
    CoreMapCallbacks callbacks = widget.callbacks ?? CoreMapCallbacks();
    return _buildMap(
      type: widget.type,
      data: widget.data.copyWith(
          initialCameraPosition: _controller?.getCurrentPosition() ?? widget.data.initialCameraPosition
      ),
      shapes: widget.shapes,
      callbacks: callbacks.copyWith(
        onMapCreated: (controller) {
          _controller = controller;
          widget.callbacks?.onMapCreated?.call(controller);
        },
      ),
    );
  }

  Widget _buildMap({
    required CoreMapType type,
    required CoreMapData data,
    CoreMapShapes? shapes,
    CoreMapCallbacks? callbacks,
  }) {
    switch (type) {
      case CoreMapType.google:
        return _CoreGoogleMap(
          data: data,
          callbacks: callbacks,
          shapes: shapes ?? CoreMapShapes(),
        );
      case CoreMapType.viettel:
        return _CoreViettelMap(
          data: data,
          callbacks: callbacks,
          userLocationDrawOptions: _locationManager.getViettelUserLocationDrawOptions(),
          shapes: shapes ?? CoreMapShapes()
        );
    }
  }
}