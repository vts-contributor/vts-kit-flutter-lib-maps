part of core_map;

class _RoutingManagerImpl extends ChangeNotifier implements RoutingManager {

  final _LocationManager _locationManager;

  CoreMapController? mapController;

  _RoutingManagerImpl(this._locationManager);

  Directions? _directions;

  String? _currentSelectedId;

  Color _selectedColor = Colors.blue;

  Color _unselectedColor = Colors.grey;

  final List<void Function(String id)> _routeSelectedListeners = [];

  String? _getSelectedId([Directions? directions]) {
    _currentSelectedId ??= directions?.routes?.firstOrNull?.id;
    return _currentSelectedId;
  }

  void updateColor(Color selected, Color unselected) {
    _selectedColor = selected;
    _unselectedColor = unselected;
    //don't need to call notify listener here.
  }

  @override
  Future<void> buildDirections(Directions directions) async {
    _clearOldDirections();
    _directions = directions;
    await _moveCameraToSelectedBounds(directions);
    notifyListeners();
  }

  @override
  Future<void> startNavigation() {
    // TODO: implement startNavigation
    throw UnimplementedError();
  }

  void _clearOldDirections() {
    _directions = null;
    _currentSelectedId = null;
  }

  Future<void> _moveCameraToSelectedBounds(Directions directions) async {
    if (mapController == null) return;

    String? selectedId = _getSelectedId(directions);

    ViewPort? bounds = directions.routes?.firstWhereOrNull(
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

    Directions? directions = _directions;
    if (directions != null) {
      shapes.polylines.addAll(_buildPolylinesFromDirections(directions));
    }

    return shapes;
  }

  Set<Polyline> _buildPolylinesFromDirections(Directions directions) {

    List<MapRoute>? routes = directions.routes;
    if (routes == null) return {};

    String? selectedId = _getSelectedId(directions);

    return routes.map((e) => _buildPolylineFromRoute(e, e.id == selectedId)).toSet();
  }

  Polyline _buildPolylineFromRoute(MapRoute route, bool isSelected) {
    return Polyline(
      id: PolylineId(route.id),
      points: route.points ?? [],
      color: isSelected? _selectedColor: _unselectedColor,
      zIndex: isSelected? 6: 5,
      jointType: JointType.round,
      onTap: () {
        Log.d("ROUTING", "ontap");
        _setSelectedId(route.id);
      }
    );
  }

  void _setSelectedId(String id) {
    if (id != _getSelectedId()) {
      _currentSelectedId = id;
      notifyListeners();
      notifyRouteSelectedListener(id);
    }
  }

  @override
  void addRouteSelectedListener(void Function(String id) listener) {
    _routeSelectedListeners.add(listener);
  }

  @override
  void removeRouteSelectedListener(void Function(String id) listener) {
    _routeSelectedListeners.remove(listener);
  }

  void notifyRouteSelectedListener(String id) {
    for (final listener in _routeSelectedListeners) {
      listener(id);
    }
  }
}