part of core_map;

class _RoutingManagerImpl extends ChangeNotifier implements RoutingManager {

  final _LocationManager _locationManager;

  _RoutingManagerImpl(this._locationManager);

  Directions? _directions;

  String? _currentSelectedId;

  Color _selectedColor = Colors.blue;

  Color _unselectedColor = Colors.grey;

  String? _getSelectedId(Directions directions) {
    _currentSelectedId ??= directions.routes?.firstOrNull?.id;
    return _currentSelectedId;
  }

  @override
  Future<void> buildDirections(Directions directions) async {
    _directions = directions;
    notifyListeners();
  }

  @override
  Future<void> startNavigation() {
    // TODO: implement startNavigation
    throw UnimplementedError();
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

    return routes.map((e) => _buildPolylineFromRoute(e, selectedId)).toSet();
  }

  Polyline _buildPolylineFromRoute(MapRoute route, String? selectedId) {
    bool isSelected = route.id == selectedId;
    return Polyline(
      id: PolylineId(route.id),
      points: route.points ?? [],
      color: isSelected? _selectedColor: _unselectedColor,
      zIndex: isSelected? 6: 5,
      jointType: JointType.round
    );
  }

  @override
  set selectedRouteColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  @override
  set unselectedRouteColor(Color color) {
    _unselectedColor = color;
    notifyListeners();
  }

}