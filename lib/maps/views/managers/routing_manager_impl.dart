part of core_map;

class _RoutingManagerImpl extends ChangeNotifier implements RoutingManager {
  static const int MAX_DESTINATION_FOR_DISTANCE_MATRIX = 45;

  final _LocationManager _locationManager;

  String? _token;

  CoreMapController? mapController;

  _RoutingManagerImpl(this._locationManager);

  List<MapRoute>? _routes;

  final Map<String, MapRoute?> _localCachedRoute = {};

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

  RouteCachingStrategy? _cachingStrategy = _DefaultRouteCachingStrategy();

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

    ViewPort? bounds = routes.firstWhereOrNull((e) => e.id == selectedId)?.bounds;

    LatLng? northeast = bounds?.northeast;
    LatLng? southwest = bounds?.southwest;

    if (northeast != null && southwest != null) {
      await mapController?.animateCamera(CameraUpdate.newLatLngBounds(
          LatLngBounds(southwest: southwest, northeast: northeast), 1));
    }
  }

  ///combine [originalShape] with routing shapes
  @override
  CoreMapShapes modifyShapes(CoreMapShapes? original) {
    CoreMapShapes shapes = original?.clone() ?? CoreMapShapes();

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
      debugPrint("list points length: ${listPoint.length}");
      return Polyline(
          id: PolylineId(const Uuid().v4()),
          points: listPoint,
          color: route.config?.color ?? (isSelected ? _selectedColor : _unselectedColor),
          zIndex: route.config?.zIndex ?? (isSelected ? 6 : 5),
          jointType: JointType.round,
          width: route.config?.width ??
              ((isSelected ? _selectedWidth : _unselectedWidth) ?? _defaultWidth),
          onTap: () {
            Log.d("ROUTING", "ontap");
            if (route.config?.selectOnTap == true) {
              selectRoute(route.id);
            }
            notifyRouteTapListeners(route.id);
          });
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
  bool selectRoute(
    String id, {
    bool zoomToRoute = true,
  }) {
    if (_routes == null) {
      Log.e(RoutingManager.logTag, "Can't select route when directions are null");
      return false;
    }

    MapRoute? route = _routes?.firstWhereOrNull((e) => e.id == id);
    if (route == null) return false;

    _setSelectedId(id);

    if (zoomToRoute) {
      _viewRoutes([route]);
    }

    return true;
  }

  void _viewRoutes(List<MapRoute> routes, [double? padding]) {
    List<LatLng> points =
        routes.map((e) => e.tryGetNonNullOrEmptyPoints() ?? []).flattened.toList();
    if (points.isNotEmpty) {
      mapController?.animateCameraToCenterOfPoints(points, padding ?? 10, duration: 1);
    }
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
      mapRoute = _localCachedRoute[routeConfig.id];
    } else {
      _localCachedRoute.remove(routeConfig.id);
    }

    try {
      if (mapRoute == null) {
        List<LatLng> waypoints;
        if (routeConfig.routeType == RouteType.autoSort) {
          waypoints = await sortWaypoints(routeConfig.waypoints, routeConfig.travelMode);
        } else {
          waypoints = routeConfig.waypoints;
        }

        Directions? directions =
            await _getDirections(waypoints, routeConfig.routeType, routeConfig.travelMode);
        mapRoute = directions?.routes?.trySelectShortestRoute();
        mapRoute?.sortedWaypoints = waypoints;
      }
      _routes?.remove(placeHolder);
    } catch (e, s) {
      _routes?.remove(placeHolder);
    }

    if (mapRoute != null) {
      mapRoute.id = routeConfig.id;
      mapRoute.config = routeConfig;

      _routes ??= [];

      _routes?.add(mapRoute);

      if (routeConfig.cached) {
        _localCachedRoute.putIfAbsent(routeConfig.id, () => mapRoute);
      }

      if (shouldNotify) notifyListeners();
    }
  }

  Future<Directions?> _getDirections(
      List<LatLng> waypoints, RouteType type, RouteTravelMode? travelMode) async {
    switch (type) {
      case RouteType.auto:
      case RouteType.autoSort:
        return _getAutoRoutesDirection(waypoints, travelMode);
      case RouteType.line:
        return Directions(routes: [MapRoute(id: "", points: waypoints)]);
    }
  }

  Future<Directions?> _getAutoRoutesDirection(
      List<LatLng> waypoints, RouteTravelMode? travelMode) async {
    if (waypoints.length < 2) {
      return Future.value(null);
    }

    travelMode ??= _defaultTravelMode;

    String cachingKey = _getDirectionCachingKey(waypoints, travelMode);
    String? jsonString = await _cachingStrategy?.get(cachingKey);

    Directions? directions;
    if (jsonString == null) {
      directions = await MapsAPIServiceImpl(key: _token).direction(
        originLat: waypoints.first.latitude,
        originLng: waypoints.first.longitude,
        destLat: waypoints.last.latitude,
        destLng: waypoints.last.longitude,
        alternatives: true,
        waypoints: waypoints,
        mode: travelMode?.name,
        onReceiveJson: (json) {
          _cachingStrategy?.save(cachingKey, jsonEncode(json));
        },
      );
    } else {
      directions = Directions.fromJson(jsonDecode(jsonString));
    }

    return directions;
  }

  String _getDirectionCachingKey(List<LatLng> waypoints, RouteTravelMode? travelMode) {
    String encodedPolyline = PolylineCodec.encode(waypoints);
    return "$encodedPolyline ${travelMode?.toString()}";
  }

  Future<List<LatLng>> sortWaypoints(List<LatLng> points, RouteTravelMode? travelMode) async {
    if (points.length <= 2) {
      return points;
    }

    Map<String, Map<String, DistanceMatrixElement>>? distanceMap =
        await _getDistanceMapping(points, travelMode);

    if (distanceMap == null) {
      return points;
    }

    // for (Map<String, DistanceMatrixElement> distanceMapOfPoint in distanceMap.values) {
    //
    // }

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
        if (sortedPoints
            .where((element) => element.toString().compareTo(mapEntry.key) == 0)
            .isEmpty) {
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
        Log.e("AUTO SORT ROUTING ERROR",
            "Sorting number of points becomes larger than original points");
        return points;
      }
    }

    return sortedPoints;
  }

  Future<Map<String, Map<String, DistanceMatrixElement>>?> _getDistanceMapping(
      List<LatLng> points, RouteTravelMode? travelMode) async {
    try {
      points = _sortListPoints(points);

      String cachingKey = _getDistanceMatrixCachingKey(points);
      String? jsonString = await _cachingStrategy?.get(cachingKey);
      String listDivider = '\$';
      String itemDivider = '!';

      List<List<LatLng>> slices = points.slices(MAX_DESTINATION_FOR_DISTANCE_MATRIX).toList();

      List<DistanceMatrix> listMatrix;

      if (jsonString == null) {
        StringBuffer newJsonString = StringBuffer();

        List<Future<DistanceMatrix>> listFuture = [];

        for (int i = 0; i < slices.length; i++) {
          for (int j = 0; j < slices.length; j++) {
            List<LatLng> origins = slices[i];
            List<LatLng> destinations = slices[j];

            String id = "$i/$j";

            listFuture.add(MapsAPIServiceImpl(key: _token).getDistanceMatrix(
              origins: origins,
              destinations: destinations,
              travelMode: (travelMode ?? _defaultTravelMode),
              id: id,
              onReceiveJson: (json) {
                newJsonString.write("${jsonEncode(json)}$itemDivider$id$listDivider");
              },
            ));
          }
        }

        listMatrix = await Future.wait(listFuture);

        _cachingStrategy?.save(cachingKey, newJsonString.toString());
      } else {
        listMatrix = List.empty(growable: true);

        List<String> matrixItemsCache = jsonString.split(listDivider);

        for (String matrixItemCache in matrixItemsCache) {
          if (matrixItemCache.isNullOrEmpty) {
            continue;
          }
          List<String> matrixItem = matrixItemCache.split(itemDivider);
          listMatrix
              .add(DistanceMatrix.fromJson(jsonDecode(matrixItem.first))..id = matrixItem.last);
        }
      }

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
              Map<String, DistanceMatrixElement>? mapDistanceOfPoint =
                  mapDistance[originSlice[i].toString()];
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

  String _getDistanceMatrixCachingKey(List<LatLng> points) {
    return "${PolylineCodec.encode(points)}}";
  }

  List<LatLng> _sortListPoints(List<LatLng> points) {
    return points.sorted((a, b) {
      int condition1 = a.latitude.compareTo(b.latitude);
      if (condition1 == 0) {
        return b.longitude.compareTo(b.longitude);
      } else {
        return condition1;
      }
    });
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
        icon: icon != null ? MarkerIcon.fromWidget(id, icon) : MarkerIcon.endIcon);
  }

  @override
  void setStartLocation(LatLng position, [Widget? icon]) {
    String id = "$position-end";
    _endMarker = Marker(
        id: MarkerId(id),
        position: position,
        icon: icon != null ? MarkerIcon.fromWidget(id, icon) : MarkerIcon.startIcon);
  }

  @override
  MapRoute? getMapRoute(String id) {
    return _routes?.where((element) => element.id == id).firstOrNull;
  }

  @override
  RouteInfo? getRouteInfo(String id) {
    return getRouteInfoFromMapRoute(_routes?.where((element) => element.id == id).firstOrNull);
  }

  RouteInfo? getRouteInfoFromMapRoute(MapRoute? mapRoute) {
    if (mapRoute == null) {
      return null;
    }
    return RouteInfo(
      mapRoute.id,
      List.from(mapRoute.sortedWaypoints ?? []),
      mapRoute.config?.routeType == RouteType.line
          ? mapRoute.points?.getTotalDistance()
          : mapRoute.legs?.getDistance(),
      mapRoute.legs?.getDuration(),
    );
  }

  @override
  void viewAllRoutes([double? padding]) {
    _viewRoutes(_routes ?? [], padding);
  }

  @override
  void viewListRoutes(List<String> ids, [double? padding]) {
    _viewRoutes(_routes?.where((element) => ids.contains(element.id)).toList() ?? [], padding);
  }

  @override
  void setCachingStrategy(RouteCachingStrategy? cachingStrategy) {
    _cachingStrategy = cachingStrategy;
  }

  @override
  Future<void> updateRoute({required String id, required LatLng currentLocation}) async {
    MapRoute? route = _routes?.firstWhereOrNull((e) => e.id == id);
    if (route != null) {
      List<LatLng>? listPoint = route.tryGetNonNullOrEmptyPoints();
      if (listPoint != null && listPoint.isNotEmpty) {
        final isOnRouteIndex = _isOnRoute(listPoint, currentLocation);
        if (isOnRouteIndex != -1) {
          int removedIndex = isOnRouteIndex;
          // 1. Remove the range from the begining to the current location
          // 2. Insert current location to the beginning of the set
          // to prevent the location marker is not on the path
          // for some cases
          if (route.points?.isNotEmpty == true) {
            route.points?.removeRange(0, removedIndex);
            route.points?.insert(0, currentLocation);
          } else {
            final points = route.pointsFromLegs;
            points?.removeRange(0, removedIndex);
            points?.insert(0, currentLocation);
            route = route.copyWith(points: points);
          }

          int? selectedRouteIndex = _routes?.indexWhere((element) => element.id == id);
          if (selectedRouteIndex != null && selectedRouteIndex != -1) {
            _updateMapRoute(route, selectedRouteIndex);
          }
        } else {
          final currentWaypoint = route.config?.waypoints;
          if (currentWaypoint != null && currentWaypoint.isNotEmpty) {
            final destination = route.config?.waypoints.last;
            if (destination != null) {
              route = route.copyWith(
                config: route.config?.copyWith(
                  waypoints: [currentLocation, destination],
                ),
              );
            }
            final config = route.config;
            if (config != null) {
              await removeRoutes(id);
              await addRoute(config);
            }
          }
        }
        notifyListeners();
      }
    }
  }

  bool _isOnSegment(LatLng currentLocation, LatLng point1, LatLng point2) {
    final distanceWaypoint = point1.getDistanceFrom(point2);
    final distanceFromStart = currentLocation.getDistanceFrom(point1);
    final distanceFromEnd = currentLocation.getDistanceFrom(point2);
    double tolerance = 10; // acceptable error value
    final diff = (distanceFromStart + distanceFromEnd - distanceWaypoint).abs();

    return diff < tolerance;
  }

  int _isOnRoute(List<LatLng> waypoints, LatLng location) {
    for (int i = 0; i < waypoints.length - 1; i++) {
      if (_isOnSegment(location, waypoints[i], waypoints[i + 1])) return i + 1;
    }
    return -1;
  }

  void _updateMapRoute(MapRoute route, int index) {
    _routes?[index] = route;
    notifyListeners();
  }
}

class _DefaultRouteCachingStrategy implements RouteCachingStrategy {
  @override
  Future<String?> get(String key) async {
    return (await SharedPreferences.getInstance()).getString(key);
  }

  @override
  Future<bool> save(String key, String content) async {
    return (await SharedPreferences.getInstance()).setString(key, content);
  }
}
