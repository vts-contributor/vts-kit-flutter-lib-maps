part of core_map;

class _InfoWindowManagerImpl extends ChangeNotifier implements InfoWindowManager {
  CoreMapController? _controller;

  final Set<_InfoWindowCoordinate> _coordinates = {};

  Set<Marker> _markers = {};

  Iterable<MarkerId> get _markerIds => _markers.map((e) => e.id);

  _InfoWindowManagerImpl(Set<Marker>? markers) {
    _markers = markers ?? {};
  }

  void updateMarkers(Set<Marker>? markers) {
    if (markers == null) return;

    _markers = markers;

    removeOldCoordinates(_markerIds);
  }

  void removeOldCoordinates(Iterable<MarkerId> newMarkerIds) {
    int oldLength = _coordinates.length;
    _coordinates.retainWhere((infoWindow) => newMarkerIds.contains(infoWindow.markerId));
    if (oldLength != _coordinates.length) notifyListeners();
  }

  void updateController(CoreMapController controller) {
    _controller = controller;
  }

  List<Widget> getInfoWindows(BuildContext context) {
    return _coordinates.map((e) => _getPositionedInfoWindow(context, e))
        .whereNotNull().toList();
  }

  Widget? _getPositionedInfoWindow(BuildContext context, _InfoWindowCoordinate coordinate) {
    Widget? widget = _markers.firstWhereOrNull(
            (element) => element.id == coordinate.markerId)?.infoWindow?.widget;

    if (widget != null) {
      widget = Positioned(
        left: coordinate.screenCoordinate.x.toDouble() / MediaQuery.of(context).devicePixelRatio,
        top: coordinate.screenCoordinate.y.toDouble() / MediaQuery.of(context).devicePixelRatio,
        child: widget,
      );
    }

    return widget;
  }

  Future<void> notifyCameraMove() async {
    await _updateInfoWindowCoordinates();
  }

  Future<void> _updateInfoWindowCoordinates() async {
    List<bool> results = await Future.wait(_coordinates.map((e) => _updateInfoWindowCoordinate(e)));
    if (results.contains(true)) notifyListeners();
  }

  Future<bool> _updateInfoWindowCoordinate(_InfoWindowCoordinate iwCoordinate) async {
    Marker? marker = _markers.firstWhereOrNull((element) => element.id == iwCoordinate.markerId);
    if (marker == null) {
      //remove invalid coordinate
      //don't notifyListeners here
      _coordinates.remove(iwCoordinate);
      return true;
    }

    ScreenCoordinate? newScreenCoordinate = await _controller?.getScreenCoordinate(marker.position);

    if (newScreenCoordinate != null) {
      if (iwCoordinate.screenCoordinate != newScreenCoordinate) {
        iwCoordinate.screenCoordinate = newScreenCoordinate;
        Log.e("TEST", "register new coordinate ${newScreenCoordinate.toString()}");
        return true;
      }
    }

    return false;
  }

  @override
  Future<void> hideInfoWindow(MarkerId markerId) async {
    int oldLength = _coordinates.length;
    _coordinates.removeWhere((e) => e.markerId == markerId);
    if (oldLength != _coordinates.length) {
      notifyListeners();
    }
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
      _coordinates.add(_InfoWindowCoordinate(
        marker.id,
        coordinate,
      ));
      notifyListeners();
    }
  }
}

class _InfoWindowCoordinate {
  MarkerId markerId;
  ScreenCoordinate screenCoordinate;

  _InfoWindowCoordinate(this.markerId, this.screenCoordinate);

  @override
  bool operator ==(Object other) {
    return other is _InfoWindowCoordinate &&
        other.markerId == markerId;
  }

  @override
  int get hashCode => Object.hash(markerId, screenCoordinate);

}