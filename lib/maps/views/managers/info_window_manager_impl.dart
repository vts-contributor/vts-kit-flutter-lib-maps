part of core_map;

class _InfoWindowManagerImpl extends ChangeNotifier implements InfoWindowManager {
  CoreMapController? _controller;

  final Map<MarkerId, _InternalInfoWindowData> _coordinates = {};

  Set<Marker> _markers = {};

  Iterable<MarkerId> get _markerIds => _markers.map((e) => e.id);

  late MarkerIconDataFactory _markerIconDataFactory;

  _InfoWindowManagerImpl(Set<Marker>? markers, MarkerIconDataFactory markerIconDataFactory) {
    _markers = markers ?? {};
    _markerIconDataFactory = markerIconDataFactory;
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

  Widget? _getPositionedInfoWindow(BuildContext context, MarkerId markerId, _InternalInfoWindowData data) {
    Marker? marker = _markers.firstWhereOrNull(
            (element) => element.id == markerId);
    Widget? widget = marker?.infoWindow?.widget;
    double? xMaxSize = marker?.infoWindow?.maxSize.width;
    double? yMaxSize = marker?.infoWindow?.maxSize.height;

    String? markerIconName = marker?.icon.data.name;
    Size? markerIconSize;
    if (markerIconName != null) {
      markerIconSize = _markerIconDataFactory.sizeOf(markerIconName);
    }

    if (widget != null) {
      final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      final x = (data.coordinate.x.toDouble() / devicePixelRatio) - (xMaxSize ?? 0)/2;
      final y = (data.coordinate.y.toDouble() / devicePixelRatio) - (yMaxSize ?? 0) - _calculateBottomOffsetOfInfoWindow(marker, markerIconSize);
      widget = Positioned(
        left: x,
        top: y,
        height: xMaxSize,
        width: yMaxSize,
        child: Center(
          child: widget,
        ),
      );
    }

    return widget;
  }

  double _calculateBottomOffsetOfInfoWindow(Marker? marker, Size? markerIconSize) {
    if (marker == null || markerIconSize == null) return 0;
    return 0;
    switch(marker.anchor) {
      case Anchor.left:
      case Anchor.right:
      case Anchor.center:
        return markerIconSize.height / 2;
      case Anchor.topLeft:
      case Anchor.topRight:
      case Anchor.top:
        return 1;
      case Anchor.bottomLeft:
      case Anchor.bottomRight:
      case Anchor.bottom:
      return markerIconSize.height / 2;
    }
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
        _coordinates.keys.map((key) =>_updateInfoWindowCoordinate(key)).toList());
    if (results.contains(true)) notifyListeners();
  }

  Future<bool> _updateInfoWindowCoordinate(MarkerId markerId) async {
    Marker? marker = _markers.firstWhereOrNull((element) => element.id == markerId);
    if (marker == null) {
      //remove invalid coordinate
      //don't notifyListeners here
      _coordinates.remove(markerId);
      return true;
    }

    ScreenCoordinate? newScreenCoordinate = await _controller?.getScreenCoordinate(marker.position);
    ScreenCoordinate? oldScreenCoordinate = _coordinates[markerId]?.coordinate;

    if (newScreenCoordinate != null) {
      if (oldScreenCoordinate != newScreenCoordinate) {
        _coordinates.update(markerId, (value) => _InternalInfoWindowData(value.size, newScreenCoordinate));
        Log.d(InfoWindowManager.logTag, "register new screen coordinate ${newScreenCoordinate.toString()} for marker ${markerId.toString()}");
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
      _coordinates.putIfAbsent(marker.id, () => _InternalInfoWindowData(Size.zero, coordinate));
      notifyListeners();
    }
  }
}

class _InternalInfoWindowData {
  Size size;
  ScreenCoordinate coordinate;

  _InternalInfoWindowData(this.size, this.coordinate);
}