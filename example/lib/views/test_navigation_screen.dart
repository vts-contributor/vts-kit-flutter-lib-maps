import 'package:flutter/material.dart';
import 'package:maps_core/maps.dart';
import 'package:geolocator/geolocator.dart';

class TestNavigationScreen extends StatefulWidget {
  const TestNavigationScreen({Key? key}) : super(key: key);

  static const String routeName = "TestNavigationScreen";

  @override
  State<TestNavigationScreen> createState() => _TestNavigationScreenState();
}

class _TestNavigationScreenState extends State<TestNavigationScreen> {
  RoutingManager? _routingManager;
  CoreMapController? _mapController;
  LatLng start = const LatLng(10.77812934094144, 106.68004987064614);
  LatLng destination = const LatLng(10.800539399606146, 106.68685715445667);
  late LatLng userLocation = start;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test navigation"),
      ),
      body: CoreMap(
        type: CoreMapType.google,
        data: CoreMapData(
          accessToken: "ad903093bbefba04624d5e742e155e30",
          initialCameraPosition: CameraPosition(target: start, zoom: 15),
          compassEnabled: true,
          myLocationEnabled: true,
          myLocationButtonAlignment: Alignment.bottomRight,
          markerAllowOverlap: true,
          selectedRouteWidth: 12,
          unselectedRouteWidth: 10,
        ),
        callbacks: CoreMapCallbacks(
          onRoutingManagerReady: (manager) {
            onRoutingReady(manager);
          },
          onMapCreated: (manager) {
            debugPrint("onMapCreated");
            onMapReady(manager);
          },
          onUserLocationUpdated: (userLocation) {
            _onUserLocationUpdate(userLocation);
          },
        ),
        shapes: CoreMapShapes(markers: {
          Marker(
            id: const MarkerId("destination"),
            position: destination,
          ),
        }),
      ),
      bottomNavigationBar: _buildBottom(context),
    );
  }

  Widget _buildBottom(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text("${_routingManager?.getRouteInfo("1")?.totalDuration}"),
    );
  }

  Future<void> onMapReady(CoreMapController controller) async {
    _mapController = controller;
    _updateCameraCenter();
  }

  Future<void> onRoutingReady(RoutingManager manager) async {
    _routingManager = manager;
    RouteConfig routeConfig = RouteConfig("1", [start, destination], color: Colors.black);
    Future.delayed(const Duration(milliseconds: 500), () {
      // _routingManager?.removeRoutes("1");
      _routingManager?.addRoute(routeConfig);
    });
  }

  Future<void> _updateCameraCenter() async {
    Future.delayed(const Duration(milliseconds: 500), () async {
      _mapController?.animateCameraToCenterOfPoints(
        [userLocation, destination],
        60,
      );
    });
  }

  Future<void> _onUserLocationUpdate(Position location) async {
    await _routingManager?.updateRoute(
      id: "1",
      currentLocation: LatLng(location.latitude, location.longitude),
    );
  }
}
