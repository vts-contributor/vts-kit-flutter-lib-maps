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

    if (marker?.infoWindow == null) return null;

    Widget? widget = marker?.infoWindow?.widget;

    if (widget != null) {
      final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

      double? xMaxSize = marker?.infoWindow?.maxSize.width;
      double? yMaxSize = marker?.infoWindow?.maxSize.height;

      String? markerIconName = marker?.icon.data.name;
      Size? markerIconSize;
      if (markerIconName != null) {
        markerIconSize = _markerIconDataFactory.sizeOf(markerIconName);
      }

      final x = (data.coordinate.x.toDouble() / devicePixelRatio) - (xMaxSize ?? 0)/2;
      final y = (data.coordinate.y.toDouble() / devicePixelRatio) - (yMaxSize ?? 0)
          - _calculateBottomOffsetOfInfoWindow(marker, markerIconSize, devicePixelRatio);
      widget = Positioned(
        left: x,
        top: y,
        height: xMaxSize,
        width: yMaxSize,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: widget,
        ),
      );
    }

    return widget;
  }

  double _calculateBottomOffsetOfInfoWindow(Marker? marker, Size? markerIconSize, double devicePixelRatio) {
    if (marker == null || markerIconSize == null) return 0;
    Size markerIconSizeByDP = Size(markerIconSize.width / devicePixelRatio, markerIconSize.height / devicePixelRatio);
    double offset = marker.infoWindow?.bottomOffset ?? 0;
    switch(marker.anchor) {
      case Anchor.left:
      case Anchor.right:
      case Anchor.center:
        offset += markerIconSizeByDP.height / 2;
        break;
      case Anchor.topLeft:
      case Anchor.topRight:
      case Anchor.top:
        offset += 0;
        break;
      case Anchor.bottomLeft:
      case Anchor.bottomRight:
      case Anchor.bottom:
        offset += markerIconSizeByDP.height;
        break;
    }
    return offset;
  }

  @override
  void onMarkerTapSetInfoWindow(MarkerId markerId) {
    if (_coordinates.containsKey(markerId)) {
      hideInfoWindow(markerId);
    } else {
      showInfoWindow(markerId);
    }
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