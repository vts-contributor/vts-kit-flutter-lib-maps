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

  LatLng firstPoint2 = const LatLng(10.83781439676659, 106.67346659058827);
  LatLng secondPoint2 = const LatLng(10.846372, 106.675161);

  RoutingManager? _routingManager;

  CoreMapType _type = CoreMapType.viettel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                await _routingManager?.removeRoutes("1234");
              },
              icon: const Icon(Icons.delete)),
          IconButton(
              onPressed: () async {
                await _routingManager?.clearAllRoutes();
              },
              icon: const Icon(Icons.delete)),
          IconButton(
              onPressed: () async {
                await _routingManager?.addRoute(RouteConfig("1234", [
                  LatLng(10.867235213747376, 106.63784199919601),
                  LatLng(10.868763097854528, 106.63776311415448),
                  LatLng(10.868543599492142, 106.63907348234407),
                  LatLng(10.869400072580289, 106.63860017209498),
                  LatLng(10.889305387234123, 106.63943723003548),
                  LatLng(10.869305387234123, 106.63943723003548),
                  LatLng(10.869605387234123, 106.63943723003548),
                  LatLng(10.869805387234123, 106.63943723003548),
                  LatLng(10.879305387234123, 106.63943723003548),
                  LatLng(10.871305387234123, 106.63943723003548),
                  LatLng(10.872305387234123, 106.63943723003548),
                  LatLng(10.873305387234123, 106.63943723003548),
                  LatLng(10.874305387234123, 106.63943723003548),
                  LatLng(10.875305387234123, 106.63943723003548),
                  LatLng(10.876305387234123, 106.63943723003548),
                  LatLng(10.877305387234123, 106.63943723003548),
                  LatLng(10.878305387234123, 106.63943723003548),
                  LatLng(10.879305387234123, 106.63943723003548),
                  LatLng(10.880305387234123, 106.63943723003548),
                  LatLng(10.881305387234123, 106.63943723003548),
                  LatLng(10.882305387234123, 106.63943723003548),
                  LatLng(10.883305387234123, 106.63943723003548),
                  LatLng(10.884305387234123, 106.63943723003548),
                  LatLng(10.885305387234123, 106.63943723003548),
                  LatLng(10.886305387234123, 106.63943723003548),
                  LatLng(10.887305387234123, 106.63943723003548),
                  LatLng(10.888305387234123, 106.63943723003548),
                  LatLng(10.889305387234123, 106.63943723003548),
                  LatLng(10.890305387234123, 106.63943723003548),
                  LatLng(10.891305387234123, 106.63943723003548),
                  LatLng(10.892305387234123, 106.63943723003548),
                  LatLng(10.893305387234123, 106.63943723003548),
                  LatLng(10.894305387234123, 106.63943723003548),
                  LatLng(10.895305387234123, 106.63943723003548),
                  LatLng(10.896305387234123, 106.63943723003548),
                  LatLng(10.897305387234123, 106.63943723003548),
                  LatLng(10.898305387234123, 106.63943723003548),
                  LatLng(10.899305387234123, 106.63943723003548),
                  LatLng(10.900305387234123, 106.63943723003548),
                  LatLng(10.910305387234123, 106.63943723003548),
                  LatLng(10.920305387234123, 106.63943723003548),
                  LatLng(10.930305387234123, 106.63943723003548),
                  LatLng(10.940305387234123, 106.63943723003548),
                  LatLng(10.950305387234123, 106.63943723003548),
                  LatLng(10.960305387234123, 106.63943723003548),
                  LatLng(10.867235213747376, 106.63784199919601),
                  LatLng(10.868763097854528, 106.63776311415448),
                  LatLng(10.868543599492142, 106.63907348234407),
                  LatLng(10.869400072580289, 106.63860017209498),
                  LatLng(10.889305387234123, 106.63943723003548),
                  LatLng(10.869305387234123, 106.63943723003548),
                  LatLng(10.869605387234123, 106.63943723003548),
                  LatLng(10.869805387234123, 106.63943723003548),
                  LatLng(10.879305387234123, 106.63943723003548),
                  LatLng(10.871305387234123, 106.63943723003548),
                  LatLng(10.872305387234123, 106.63943723003548),
                  LatLng(10.873305387234123, 106.63943723003548),
                  LatLng(10.874305387234123, 106.63943723003548),
                  LatLng(10.875305387234123, 106.63943723003548),
                  LatLng(10.876305387234123, 106.63943723003548),
                  LatLng(10.877305387234123, 106.63943723003548),
                  LatLng(10.878305387234123, 106.63943723003548),
                  LatLng(10.879305387234123, 106.63943723003548),
                  LatLng(10.880305387234123, 106.63943723003548),
                  LatLng(10.881305387234123, 106.63943723003548),
                  LatLng(10.882305387234123, 106.63943723003548),
                  LatLng(10.883305387234123, 106.63943723003548),
                  LatLng(10.884305387234123, 106.63943723003548),
                  LatLng(10.885305387234123, 106.63943723003548),
                  LatLng(10.886305387234123, 106.63943723003548),
                  LatLng(10.887305387234123, 106.63943723003548),
                  LatLng(10.888305387234123, 106.63943723003548),
                  LatLng(10.889305387234123, 106.63943723003548),
                  LatLng(10.890305387234123, 106.63943723003548),
                  LatLng(10.891305387234123, 106.63943723003548),
                  LatLng(10.892305387234123, 106.63943723003548),
                  LatLng(10.893305387234123, 106.63943723003548),
                  LatLng(10.894305387234123, 106.63943723003548),
                  LatLng(10.895305387234123, 106.63943723003548),
                  LatLng(10.896305387234123, 106.63943723003548),
                  LatLng(10.897305387234123, 106.63943723003548),
                  LatLng(10.898305387234123, 106.63943723003548),
                  LatLng(10.899305387234123, 106.63943723003548),
                  LatLng(10.900305387234123, 106.63943723003548),
                  LatLng(10.910305387234123, 106.63943723003548),
                  LatLng(10.920305387234123, 106.63943723003548),
                  LatLng(10.930305387234123, 106.63943723003548),
                  LatLng(10.940305387234123, 106.63943723003548),
                  LatLng(10.950305387234123, 106.63943723003548),
                  LatLng(10.960305387234123, 106.63943723003548),
                  LatLng(10.867235213747376, 106.63784199919601),
                  LatLng(10.868763097854528, 106.63776311415448),
                  LatLng(10.868543599492142, 106.63907348234407),
                  LatLng(10.869400072580289, 106.63860017209498),
                  LatLng(10.889305387234123, 106.63943723003548),
                  LatLng(10.869305387234123, 106.63943723003548),
                  LatLng(10.869605387234123, 106.63943723003548),
                  LatLng(10.869805387234123, 106.63943723003548),
                  LatLng(10.879305387234123, 106.63943723003548),
                  LatLng(10.871305387234123, 106.63943723003548),
                  LatLng(10.872305387234123, 106.63943723003548),
                  LatLng(10.873305387234123, 106.63943723003548),
                  LatLng(10.874305387234123, 106.63943723003548),
                  LatLng(10.875305387234123, 106.63943723003548),
                  LatLng(10.876305387234123, 106.63943723003548),
                  LatLng(10.877305387234123, 106.63943723003548),
                  LatLng(10.878305387234123, 106.63943723003548),
                  LatLng(10.879305387234123, 106.63943723003548),
                  LatLng(10.880305387234123, 106.63943723003548),
                  LatLng(10.881305387234123, 106.63943723003548),
                  LatLng(10.882305387234123, 106.63943723003548),
                  LatLng(10.883305387234123, 106.63943723003548),
                  LatLng(10.884305387234123, 106.63943723003548),
                  LatLng(10.885305387234123, 106.63943723003548),
                  LatLng(10.886305387234123, 106.63943723003548),
                  LatLng(10.887305387234123, 106.63943723003548),
                  LatLng(10.888305387234123, 106.63943723003548),
                  LatLng(10.889305387234123, 106.63943723003548),
                  LatLng(10.890305387234123, 106.63943723003548),
                  LatLng(10.891305387234123, 106.63943723003548),
                  LatLng(10.892305387234123, 106.63943723003548),
                  LatLng(10.893305387234123, 106.63943723003548),
                  LatLng(10.894305387234123, 106.63943723003548),
                  LatLng(10.895305387234123, 106.63943723003548),
                  LatLng(10.896305387234123, 106.63943723003548),
                  LatLng(10.897305387234123, 106.63943723003548),
                  LatLng(10.898305387234123, 106.63943723003548),
                  LatLng(10.899305387234123, 106.63943723003548),
                  LatLng(10.900305387234123, 106.63943723003548),
                  LatLng(10.910305387234123, 106.63943723003548),
                  LatLng(10.920305387234123, 106.63943723003548),
                  LatLng(10.930305387234123, 106.63943723003548),
                  LatLng(10.940305387234123, 106.63943723003548),
                  LatLng(10.950305387234123, 106.63943723003548),
                  LatLng(10.960305387234123, 106.63943723003548),
                ], routeType: RouteType.autoSort, color: Colors.blueAccent));
              },
              icon: const Icon(Icons.swap_vert_circle)),
          IconButton(
              onPressed: () async {
                await _routingManager?.addRoute(RouteConfig("123", [firstPoint, secondPoint], color: Colors.black));
                _routingManager?.selectRoute("123");
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
                _routingManager?.setStartLocation(firstPoint);
                _routingManager?.setEndLocation(secondPoint);
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
          markerAllowOverlap: true,
          selectedRouteWidth: 12,
          unselectedRouteWidth: 10,
        ),
        callbacks: CoreMapCallbacks(onRoutingManagerReady: (manager) {
          _routingManager = manager;
          _routingManager?.addRouteTapListener((id) {
            Log.d("TEST ROUTING SCREEN", "new route selected $id");
          });
        },
        onMapCreated: (manager) {
          debugPrint("onMapCreated");
        }),
      ),
    );
  }
}
