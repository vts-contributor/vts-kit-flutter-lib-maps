part of core_map;

class _InfoWindowManagerImpl extends ChangeNotifier implements InfoWindowManager {
  CoreMapController? _controller;

  final Map<MarkerId, ScreenCoordinate> _coordinates = {};

  Set<Marker> _markers = {};

  Iterable<MarkerId> get _markerIds => _markers.map((e) => e.id);

  _InfoWindowManagerImpl(Set<Marker>? markers) {
    _markers = markers ?? {};
  }

  void updateMarkers(Set<Marker>? markers) {
    if (markers == null) return;

    _markers = markers;

    validateInfoWindows(_markerIds);
  }

  ///remove old markers
  void validateInfoWindows(Iterable<MarkerId> newMarkerIds) {
    int oldLength = _coordinates.length;
    _coordinates.removeWhere((key, value) => !newMarkerIds.contains(key));
    if (oldLength != _coordinates.length) notifyListeners();
  }

  void updateController(CoreMapController controller) {
    _controller = controller;
  }

  List<Widget> getInfoWindows(BuildContext context) {
    return _coordinates
        .map((key, value) => MapEntry(key, _getPositionedInfoWindow(context, key, value)))
        .values.whereNotNull().toList();
  }

  Widget? _getPositionedInfoWindow(BuildContext context, MarkerId markerId, ScreenCoordinate coordinate) {
    Widget? widget = _markers.firstWhereOrNull(
            (element) => element.id == markerId)?.infoWindow?.widget;

    if (widget != null) {
      final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      widget = Positioned(
        left: coordinate.x.toDouble() / devicePixelRatio,
        top: coordinate.y.toDouble() / devicePixelRatio,
        child: Align(
          alignment: Alignment.center,
          child: widget,
        ),
      );
    }

    return widget;
  }

  void onMarkerTap(MarkerId markerId) {
    if (_coordinates.containsKey(markerId)) {
      hideInfoWindow(markerId);
    } else {
      showInfoWindow(markerId);
    }
  }

  CoreMapShapes? overrideShapes(CoreMapShapes? originalShapes) {
    return originalShapes?.copyWith(
      markers: originalShapes.markers.map((e) => e.copyWith(
        onTapParam: () {
          e.onTap?.call();
          onMarkerTap(e.id);
        }
      )).toSet()
    );
  }

  Future<void> notifyCameraMove() async {
    await _updateInfoWindowCoordinates();
  }

  Future<void> _updateInfoWindowCoordinates() async {
    List<bool> results = await Future.wait(
        _coordinates.map((key, value) => MapEntry(key, _updateInfoWindowCoordinate(key, value))).values.toList());
    if (results.contains(true)) notifyListeners();
  }

  Future<bool> _updateInfoWindowCoordinate(MarkerId markerId, ScreenCoordinate oldScreenCoordinate) async {
    Marker? marker = _markers.firstWhereOrNull((element) => element.id == markerId);
    if (marker == null) {
      //remove invalid coordinate
      //don't notifyListeners here
      _coordinates.remove(markerId);
      return true;
    }

    ScreenCoordinate? newScreenCoordinate = await _controller?.getScreenCoordinate(marker.position);

    if (newScreenCoordinate != null) {
      if (oldScreenCoordinate != newScreenCoordinate) {
        _coordinates.update(markerId, (_) => newScreenCoordinate);
        return true;
      }
    }

    return false;
  }

  @override
  Future<void> hideInfoWindow(MarkerId markerId) async {
    if (_coordinates.remove(markerId) != null) notifyListeners();
  }

  @override
  Future<void> showInfoWindow(MarkerId markerId) async {
    Marker? marker = _markers.firstWhereOrNull((element) => element.id == markerId);
    if (marker == null) {
      Log.e(InfoWindowManager.logTag, "${markerId.value} does not exist in the marker set");
      return;
    }

    _addNewInfoWindowCoordinate(marker);
  }

  Future<void> _addNewInfoWindowCoordinate(Marker marker) async {
    ScreenCoordinate? coordinate = await _controller?.getScreenCoordinate(marker.position);

    if (coordinate != null) {
      _coordinates.putIfAbsent(marker.id, () => coordinate);
      notifyListeners();
    }
  }
}