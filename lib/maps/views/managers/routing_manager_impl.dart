part of core_map;

class _RoutingManagerImpl extends ChangeNotifier implements RoutingManager {

  final _LocationManager _locationManager;

  CoreMapController? mapController;

  _RoutingManagerImpl(this._locationManager);

  List<MapRoute>? _routes;

  String? _currentSelectedId;

  Color _selectedColor = Colors.blue;

  Color _unselectedColor = Colors.grey;

  int? _selectedWidth;

  int? _unselectedWidth;

  final int _defaultWidth = 10;

  final List<void Function(String id)> _routeSelectedListeners = [];

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



  @override
  Future<void> buildRoutes(List<MapRoute>? routes) async {
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
    _currentSelectedId = _routes?.firstOrNull?.id;
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
          40));
    }
  }

  ///combine [originalShape] with routing shapes
  CoreMapShapes combineShape(CoreMapShapes? originalShape) {
    CoreMapShapes shapes = originalShape ?? CoreMapShapes();

    List<MapRoute>? routes = _routes;
    if (routes != null) {
      shapes.polylines.addAll(_buildPolylinesFromDirections(routes));
    }

    return shapes;
  }

  Set<Polyline> _buildPolylinesFromDirections(List<MapRoute> routes) {
    String? selectedId = _currentSelectedId;
    return routes.map((e) => _buildPolylineFromRoute(e, e.id == selectedId)).toSet();
  }

  Polyline _buildPolylineFromRoute(MapRoute route, bool isSelected) {
    return Polyline(
      id: PolylineId(route.id),
      points: route.points ?? [],
      color: isSelected? _selectedColor: _unselectedColor,
      zIndex: isSelected? 6: 5,
      jointType: JointType.round,
      width: (isSelected? _selectedWidth: _unselectedWidth) ?? _defaultWidth,
      onTap: () {
        Log.d("ROUTING", "ontap");
        _setSelectedId(route.id);
        notifyRouteTapListeners(route.id);
      }
    );
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
  bool selectRoute(String id) {
    if (_routes == null) {
      Log.e(RoutingManager.logTag, "Can't select route when directions are null");
      return false;
    }

    MapRoute? route = _routes?.firstWhereOrNull((e) => e.id == id);
    if (route == null) return false;

    _setSelectedId(id);

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
}