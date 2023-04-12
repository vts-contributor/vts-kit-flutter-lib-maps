import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'package:maps_core/log/log.dart';

import 'package:maps_core/maps.dart';
import 'package:maps_core/maps/views/core_google_map.dart';
import 'package:maps_core/maps/views/core_viettel_map.dart';
import 'package:rxdart/rxdart.dart';

part 'location_manager.dart';

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
        return CoreGoogleMap(
          data: data,
          callbacks: callbacks,
          shapes: shapes ?? CoreMapShapes(),
        );
      case CoreMapType.viettel:
        return CoreViettelMap(
          data: data,
          callbacks: callbacks,
          shapes: shapes ?? CoreMapShapes()
        );
    }
  }
}