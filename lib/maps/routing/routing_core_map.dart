import 'package:flutter/cupertino.dart';
import 'package:maps_core/maps.dart';
import 'package:maps_core/maps/routing/routing_manager.dart';

import 'routing_manager_impl.dart';

class RoutingCoreMap extends StatefulWidget {
  final CoreMapData data;
  final CoreMapShapes? shapes;
  final CoreMapCallbacks? callbacks;
  final CoreMapType type;
  final void Function(RoutingManager routingManager)? onRoutingManagerReady;

  const RoutingCoreMap({Key? key,
    required this.data,
    this.shapes,
    this.callbacks,
    this.type = CoreMapType.viettel,
    this.onRoutingManagerReady,
  }) : super(key: key);

  @override
  State<RoutingCoreMap> createState() => _RoutingCoreMapState();
}

class _RoutingCoreMapState extends State<RoutingCoreMap> {

  final RoutingManagerImpl _routingManager = RoutingManagerImpl();

  @override
  Widget build(BuildContext context) {
    return CoreMap(
      type: widget.type,
      data: widget.data,
      shapes: _routingManager.copyWithInternal(widget.shapes),
      callbacks: _getCallbacks(),
    );
  }

  CoreMapCallbacks _getCallbacks() {
    return (widget.callbacks ?? CoreMapCallbacks()).copyWith(
      onMapCreated: (controller) {
        _routingManager.controller = controller;
        widget.onRoutingManagerReady?.call(_routingManager);
      }
    );
  }
}
