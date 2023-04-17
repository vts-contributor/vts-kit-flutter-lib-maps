import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:map_core_example/view_models/routing_view_model.dart';
import 'package:maps_core/maps.dart';
import 'package:provider/provider.dart';

class TestRoutingScreen extends StatefulWidget {
  static const String routeName = "/test-routing-screen";
  const TestRoutingScreen({Key? key}) : super(key: key);

  @override
  State<TestRoutingScreen> createState() => _TestRoutingScreenState();
}

class _TestRoutingScreenState extends State<TestRoutingScreen> {

  //strange error case
  // LatLng firstPoint = LatLng(10.836858, 106.678863);
  // LatLng secondPoint = LatLng(10.844372, 106.673161);

  //have alternatives case
  LatLng firstPoint = LatLng(10.83581439676659, 106.67246659058827);
  LatLng secondPoint = LatLng(10.844372, 106.673161);

  RoutingManager? _routingManager;

  CoreMapType _type = CoreMapType.viettel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.swap_horiz),
            onPressed: () async {
              setState(() {
                _type = _type == CoreMapType.viettel? CoreMapType.google: CoreMapType.viettel;
              });
            },
          ),
          IconButton(onPressed: () async {
            final directions = await Provider.of<RoutingViewModel>(context, listen: false).downloadDirections(
              firstPoint,
              secondPoint
            );
            _routingManager?.buildDirections(directions);
          }, icon: Icon(Icons.download))
        ],
      ),
      body: CoreMap(
        type: _type,
        data: CoreMapData(
          accessToken: "49013166841fe36d7fa7f395fce4a663",
          initialCameraPosition: CameraPosition(
              target: firstPoint, zoom: 15),
          compassEnabled: true,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          myLocationButtonAlignment: Alignment.bottomRight,
        ),
        callbacks: CoreMapCallbacks(
          onRoutingManagerReady: (manager) {
            _routingManager = manager;
          }
        ),
      ),
    );
  }
}
