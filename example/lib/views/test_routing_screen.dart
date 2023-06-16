import 'package:flutter/material.dart';
import 'package:map_core_example/view_models/routing_view_model.dart';
import 'package:maps_core/log/log.dart';
import 'package:maps_core/maps.dart';
import 'package:provider/provider.dart';

class TestRoutingScreen extends StatefulWidget {
  static const String routeName = "/test-routing-screen";
  const TestRoutingScreen({Key? key}) : super(key: key);

  @override
  State<TestRoutingScreen> createState() => _TestRoutingScreenState();
}

class _TestRoutingScreenState extends State<TestRoutingScreen> {
  //strange api error case
  // LatLng firstPoint = LatLng(10.836858, 106.678863);
  // LatLng secondPoint = LatLng(10.844372, 106.673161);

  //have alternatives case
  LatLng firstPoint = const LatLng(10.83581439676659, 106.67246659058827);
  LatLng secondPoint = const LatLng(10.844372, 106.673161);

  RoutingManager? _routingManager;

  CoreMapType _type = CoreMapType.viettel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                await _routingManager?.buildRoutes(RoutingOptions("49013166841fe36d7fa7f395fce4a663", points: [
                  firstPoint,
                  secondPoint,
                ],
                  alternatives: true,
                ),
                );
              },
              icon: const Icon(Icons.swap_vert_circle)),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () async {
              setState(() {
                _type = _type == CoreMapType.viettel ? CoreMapType.google : CoreMapType.viettel;
              });
            },
          ),
          IconButton(
              onPressed: () async {
                final directions = await Provider.of<RoutingViewModel>(context, listen: false)
                    .downloadDirections(firstPoint, secondPoint);
                _routingManager?.buildListMapRoute(directions.routes);
              },
              icon: const Icon(Icons.download))
        ],
      ),
      body: CoreMap(
        type: _type,
        data: CoreMapData(
            accessToken: "49013166841fe36d7fa7f395fce4a663",
            initialCameraPosition: CameraPosition(target: firstPoint, zoom: 15),
            compassEnabled: true,
            myLocationEnabled: true,
            myLocationButtonAlignment: Alignment.bottomRight,

            selectedRouteColor: Colors.blue),
        callbacks: CoreMapCallbacks(onRoutingManagerReady: (manager) {
          _routingManager = manager;
          _routingManager?.addRouteTapListener((id) {
            Log.d("TEST ROUTING SCREEN", "new route selected $id");
          });
        }),
      ),
    );
  }
}
