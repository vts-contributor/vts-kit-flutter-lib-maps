part of core_map;

class _RoutingManagerImpl extends ChangeNotifier implements RoutingManager {

  static const int MAX_DESTINATION_FOR_DISTANCE_MATRIX = 45;

  final _LocationManager _locationManager;

  String? _token;

  CoreMapController? mapController;

  _RoutingManagerImpl(this._locationManager);

  List<MapRoute>? _routes;

  Map<String, MapRoute?> _cachedRoute = {};

  Marker? _startMarker;

  Marker? _endMarker;

  String? _currentSelectedId;

  Color _selectedColor = Colors.blueAccent;

  Color _unselectedColor = Colors.grey;

  int? _selectedWidth;

  int? _unselectedWidth;

  final int _defaultWidth = 8;

  final List<void Function(String id)> _routeSelectedListeners = [];

  RouteTravelMode? _defaultTravelMode;

  set token(String? value) {
    _token = value;
  }

  void updateColor(Color selected, Color unselected) {
    _selectedColor = selected;
    _unselectedColor = unselected;
    //don't need to call notify listener here.
  }

  void updateWidth(int? selected, int? unselected) {
    _selectedWidth = selected;
    _unselectedWidth = unselected;
    //don't need to call notify listener here.
  }

  void updateDefaultTravelMode(RouteTravelMode travelMode) {
    _defaultTravelMode = travelMode;
  }

  @override
  Future<void> buildListMapRoute(List<MapRoute>? routes) async {
    if (routes == null) {
      Log.e(RoutingManager.logTag, "Can't build null routes");
      return;
    }
    _clearOldDirections();
    _routes = routes;
    _pickSelectedRoute();
    await _moveCameraToSelectedBounds(routes);
    notifyListeners();
  }

  @override
  Future<void> startNavigation() {
    // TODO: implement startNavigation
    throw UnimplementedError();
  }

  void _pickSelectedRoute() async {
    _currentSelectedId = _routes?.trySelectShortestRoute()?.id;
  }

  void _clearOldDirections() {
    _routes = null;
    _currentSelectedId = null;
  }

  Future<void> _moveCameraToSelectedBounds(List<MapRoute> routes) async {
    if (mapController == null) return;

    String? selectedId = _currentSelectedId;

    ViewPort? bounds = routes.firstWhereOrNull(
            (e) => e.id == selectedId)?.bounds;

    LatLng? northeast = bounds?.northeast;
    LatLng? southwest = bounds?.southwest;

    if (northeast != null && southwest != null) {
      await mapController?.animateCamera(CameraUpdate.newLatLngBounds(
          LatLngBounds(southwest: southwest, northeast: northeast),
          1));
    }
  }

  ///combine [originalShape] with routing shapes
  CoreMapShapes combineShape(CoreMapShapes? originalShape) {
    CoreMapShapes shapes = originalShape ?? CoreMapShapes();

    List<MapRoute>? routes = _routes;
    if (routes != null) {
      shapes.polylines.addAll(_buildPolylinesFromDirections(routes));

      Marker? startMarker = _startMarker;
      if (startMarker != null) {
        shapes.markers.add(startMarker);
      }

      Marker? endMarker = _endMarker;
      if (endMarker != null) {
        shapes.markers.add(endMarker);
      }
    }

    return shapes;
  }

  Set<Polyline> _buildPolylinesFromDirections(List<MapRoute> routes) {
    String? selectedId = _currentSelectedId;
    return routes.map((e) => _buildPolylineFromRoute(e, e.id == selectedId)).whereNotNull().toSet();
  }

  Polyline? _buildPolylineFromRoute(MapRoute route, bool isSelected) {
    List<LatLng>? listPoint = route.tryGetNonNullOrEmptyPoints();
    if (listPoint != null) {
      return Polyline(
          id: PolylineId(route.id),
          points: listPoint,
          color: route.config?.color ?? (isSelected? _selectedColor: _unselectedColor),
          zIndex: isSelected? 6: 5,
          jointType: JointType.round,
          width: route.config?.width ?? ((isSelected? _selectedWidth: _unselectedWidth) ?? _defaultWidth),
          onTap: () {
            Log.d("ROUTING", "ontap");
            selectRoute(route.id);
            notifyRouteTapListeners(route.id);
          }
      );
    } else {
      return null;
    }
  }

  void _setSelectedId(String id) {
    if (id != _currentSelectedId) {
      _currentSelectedId = id;
      notifyListeners();
    }
  }

  @override
  void addRouteTapListener(void Function(String id) listener) {
    _routeSelectedListeners.add(listener);
  }

  @override
  void removeRouteTapListener(void Function(String id) listener) {
    _routeSelectedListeners.remove(listener);
  }

  void notifyRouteTapListeners(String id) {
    for (final listener in _routeSelectedListeners) {
      listener(id);
    }
  }

  @override
  bool selectRoute(String id, {
    bool zoomToRoute = true,
  }) {
    if (_routes == null) {
      Log.e(RoutingManager.logTag, "Can't select route when directions are null");
      return false;
    }

    MapRoute? route = _routes?.firstWhereOrNull((e) => e.id == id);
    if (route == null) return false;

    _setSelectedId(id);

    if (_routes != null && zoomToRoute) {
      List<LatLng>? points = route.tryGetNonNullOrEmptyPoints();
      if (points != null && points.isNotEmpty) {
        mapController?.animateCameraToCenterOfPoints(points, 10, duration: 1);
      }
    }

    return true;
  }

  @override
  MapRoute? get selectedRoute {
    String? selectedId = _currentSelectedId;
    if (selectedId != null) {
      return _routes?.firstWhereOrNull((e) => e.id == selectedId);
    } else {
      return null;
    }
  }

  @override
  Future<void> buildRoutes(RoutingOptions options) async {
    if (options.points.length >= 2) {
      // if (_buildRouteNative(options)) return;

      List<LatLng>? waypoints;
      if (options.points.length > 2) {
        waypoints = options.points.sublist(1, options.points.length - 1);
      }

      Directions direction = (await MapsAPIServiceImpl(key: options.apiKey).direction(
        originLat: options.points.first.latitude,
        originLng: options.points.first.longitude,
        destLat: options.points.last.latitude,
        destLng: options.points.last.longitude,
        mode: options.mode.toString(),
        alternatives: options.alternatives,
        waypoints: waypoints,
      ));

      buildListMapRoute(direction.routes);
    } else {
      Log.e(RoutingManager.logTag, "Can't draw a route with only 1 point");
    }
  }

  @override
  Future<void> addRoute(RouteConfig routeConfig) async {
    return _addRoute(routeConfig, true);
  }

  Future<void> _addRoute(RouteConfig routeConfig, bool shouldNotify) async {
    if (_routes?.where((element) => element.id == routeConfig.id).isNotEmpty ?? false) {
      return;
    }

    MapRoute placeHolder = MapRoute(id: routeConfig.id);
    (_routes ??= []).add(placeHolder);

    MapRoute? mapRoute;
    if (routeConfig.cached) {
      mapRoute = _cachedRoute[routeConfig.id];
    } else {
      _cachedRoute.remove(routeConfig.id);
    }

    if (mapRoute == null) {
      Directions? directions = await _getDirections(routeConfig.waypoints,
          routeConfig.routeType, routeConfig.travelMode);
      mapRoute = directions?.routes?.trySelectShortestRoute();
    }

    _routes?.remove(placeHolder);

    if (mapRoute != null) {
      mapRoute.id = routeConfig.id;
      mapRoute.config = routeConfig;

      _routes ??= [];

      _routes?.add(mapRoute);

      if (routeConfig.cached) {
        _cachedRoute.putIfAbsent(routeConfig.id, () => mapRoute);
      }

      if (shouldNotify) notifyListeners();
    }
  }

  Future<Directions?> _getDirections(List<LatLng> waypoints, RouteType type, RouteTravelMode? travelMode) async {
    switch (type) {
      case RouteType.auto:
      case RouteType.autoSort:
        return _getAutoRoutesDirection(waypoints, type, travelMode);
      case RouteType.line:
        return Directions(
          routes: [
            MapRoute(id: "", points: waypoints)
          ]
        );
    }
  }

  Future<Directions?> _getAutoRoutesDirection(List<LatLng> waypoints, RouteType type, RouteTravelMode? travelMode) async {
    if (type == RouteType.autoSort) {
      waypoints = await sortWaypoints(waypoints, travelMode);
    }

    if (waypoints.length < 2) {
      return Future.value(null);
    }

    return await MapsAPIServiceImpl(key: _token).direction(
      originLat: waypoints.first.latitude,
      originLng: waypoints.first.longitude,
      destLat: waypoints.last.latitude,
      destLng: waypoints.last.longitude,
      alternatives: true,
      waypoints: waypoints,
      mode: (travelMode ?? _defaultTravelMode)?.name
    );
  }

  Future<List<LatLng>> sortWaypoints(List<LatLng> points, RouteTravelMode? travelMode) async {
    if (points.length <= 2) {
      return points;
    }

    Map<String, Map<String, DistanceMatrixElement>>? distanceMap = await _getDistanceMapping(points, travelMode);

    if (distanceMap == null) {
      return points;
    }

    for (Map<String, DistanceMatrixElement> distanceMapOfPoint in distanceMap.values) {

    }

    List<LatLng> sortedPoints = [];
    sortedPoints.add(points.first);
    while (true) {
      LatLng currentPoint = sortedPoints.last;

      Map<String, DistanceMatrixElement>? map = distanceMap[currentPoint.toString()];
      if (map == null) {
        break;
      }

      Map<double, String> reverseDistanceMap = {};
      double? smallestDistance;
      String? nextPoint;
      for (MapEntry<String, DistanceMatrixElement> mapEntry in map.entries) {
        //if current point doesn't exist in sortedPoints
        if (sortedPoints.where((element) => element.toString().compareTo(mapEntry.key) == 0).isEmpty) {
          double? distance = mapEntry.value.distance?.value;
          if (smallestDistance == null) {
            smallestDistance = distance;
            nextPoint = mapEntry.key;
          } else {
            if (distance != null) {
              if (distance < smallestDistance) {
                smallestDistance = distance;
                nextPoint = mapEntry.key;
              }
            }
          }
        }
      }

      if (nextPoint != null) {
        sortedPoints.add(LatLng.fromString(nextPoint));
      } else {
        break;
      }

      if (sortedPoints.length > points.length) {
        Log.e("AUTO SORT ROUTING ERROR", "Sorting number of points becomes larger than original points");
        return points;
      }
    }

    return sortedPoints;
  }

  Future<Map<String, Map<String, DistanceMatrixElement>>?> _getDistanceMapping(List<LatLng> points, RouteTravelMode? travelMode) async{
    try {
      List<List<LatLng>> slices = points.slices(MAX_DESTINATION_FOR_DISTANCE_MATRIX).toList();

      List<Future<DistanceMatrix>> listFuture = [];

      for (int i = 0; i < slices.length; i++) {
        for (int j = 0; j < slices.length; j++) {
          listFuture.add(MapsAPIServiceImpl(key: _token).getDistanceMatrix(
              origins: slices[i],
              destinations: slices[j],
              travelMode: (travelMode ?? _defaultTravelMode),
              id: "$i/$j"
          ));
        }
      }

      List<DistanceMatrix> listMatrix = await Future.wait(listFuture);

      Map<String, Map<String, DistanceMatrixElement>> mapDistance = {};
      for (DistanceMatrix matrix in listMatrix) {

        List<String>? ids = matrix.id?.split("/");
        if ((ids?.length ?? 0) < 2) {
          continue;
        }

        int? originId = int.tryParse(ids?[0] ?? "-1");
        int? destinationId = int.tryParse(ids?[1] ?? "-1");

        if (originId != null && originId >= 0 && destinationId != null && destinationId >= 0) {
          List<LatLng> originSlice = slices[originId];
          List<LatLng> destinationSlice = slices[destinationId];

          for (int i = 0; i < originSlice.length; i++) {

            List<DistanceMatrixElement>? row = matrix.rows?[i];
            if (row != null) {
              String key = originSlice[i].toString();
              Map<String, DistanceMatrixElement>? mapDistanceOfPoint = mapDistance[originSlice[i].toString()];
              if (mapDistanceOfPoint == null) {
                mapDistanceOfPoint = {};
                mapDistance.putIfAbsent(key, () => mapDistanceOfPoint!);
              }

              for (int j = 0; j < destinationSlice.length; j++) {
                mapDistanceOfPoint.putIfAbsent(destinationSlice[j].toString(), () => row[j]);
              }
            }
          }
        }
      }

      return mapDistance;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  @override
  Future<void> clearAllRoutes() async {
    _clearOldDirections();
    notifyListeners();
  }

  @override
  Future<void> removeRoutes(String id) async {
    bool removed = false;
    _routes?.removeWhere((element) {
      if (element.id == id) {
        removed = true;
        return true;
      } else {
        return false;
      }
    });
    if (removed) notifyListeners();
  }

  @override
  Future<void> addRoutes(List<RouteConfig> routeConfigs) async {
    List<Future> futures = [];
    for (RouteConfig routeConfig in routeConfigs) {
      futures.add(_addRoute(routeConfig, false));
    }
    await Future.wait(futures);
    notifyListeners();
  }

  @override
  void setEndLocation(LatLng position, [Widget? icon]) {
    String id = "${position}start";
    _startMarker = Marker(
        id: MarkerId(id),
        position: position,
        icon: icon != null
            ? MarkerIcon.fromWidget(id, icon)
            : MarkerIcon.endIcon);
  }

  @override
  void setStartLocation(LatLng position, [Widget? icon]) {
    String id = "$position-end";
    _endMarker = Marker(
        id: MarkerId(id),
        position: position,
        icon: icon != null
            ? MarkerIcon.fromWidget(id, icon)
            : MarkerIcon.startIcon);
  }

  @override
  RouteInfo? getRouteInfo(String id) {
    return getRouteInfoFromMapRoute(_routes?.where((element) => element.id == id).firstOrNull);
  }

  RouteInfo? getRouteInfoFromMapRoute(MapRoute? mapRoute) {
    if (mapRoute == null) {
      return null;
    }

    List<LatLng>? points = mapRoute.points;

    return RouteInfo(points?.firstOrNull, points?.lastOrNull);
  }
}