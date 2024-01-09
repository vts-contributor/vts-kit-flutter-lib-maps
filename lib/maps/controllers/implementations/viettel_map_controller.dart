part of core_map;

class _ViettelMapController extends BaseCoreMapController {
  final vt.MapboxMapController _controller;

  //need to update both this and vtmap shape mapping when update new shapes
  CoreMapShapes _originalShapes = CoreMapShapes();

  final CameraPosition _initialCameraPosition;

  //Store core map shape id to vtmap shape mapping so that we can remove them later
  final Map<String, ViettelPolygon> _viettelPolygonMap = {};
  final Map<String, vt.Line> _viettelPolylineMap = {};
  final Map<String, ViettelCircle> _viettelCircleMap = {};
  final Map<String, vt.Symbol> _viettelMarkerMap = {};

  vt.Circle? _userLocationShape;

  //used to check if marker icon has been added
  final Set<String> _addedMarkerIconNames = {};

  final MarkerIconDataProcessor markerIconDataProcessor;

  final BitmapCacheFactory cacheFactory;

  final InfoWindowManager infoWindowManager;

  bool _styleLoaded = false;

  _ViettelMapController(this._controller, {
        required CoreMapData data,
        CoreMapCallbacks? callbacks,
        required this.markerIconDataProcessor,
        required this.cacheFactory,
        required this.infoWindowManager,
  })  : _initialCameraPosition = data.initialCameraPosition,
        super(callbacks) {
    _initHandlers();
  }

  Future<void> updateUserLocationShape(vt.CircleOptions? options) async {
    if (!_styleLoaded) return;

    vt.Circle? currentUserLocationShape = _userLocationShape;
    if (options == null) {
      if (currentUserLocationShape != null) {
        _controller.removeCircle(currentUserLocationShape);
      }
    } else {
      if (currentUserLocationShape == null) {
        _userLocationShape = await _controller.addCircle(options);
      } else {
        await _controller.updateCircle(currentUserLocationShape, options);
      }
    }
  }

  Future<void> loadNewShapes(CoreMapShapes shapes) async {
    final oldShapes = _originalShapes.toSet();
    _originalShapes = shapes.clone();
    await _validateMarkerBitmaps(_originalShapes.markers);
    await _loadNewMapObjects(oldShapes, shapes.toSet());
  }

  void updateMarkerOverlap(bool allowOverlap) async {
    _controller.setSymbolIconAllowOverlap(allowOverlap);
  }

  Future<void> _validateMarkerBitmaps(Set<Marker> markers) async {
    List<String> validNames = _originalShapes.markers.map((e) => e.icon.data.name).toList();
    List<String> invalidNames = _addedMarkerIconNames.where((element) => !validNames.contains(element)).toList();
    _addedMarkerIconNames.removeAll(invalidNames);
    for(String invalidName in invalidNames) {
      try {
        _controller.removeImageSource(invalidName);
      } catch (e) {
        Log.e(logTag, e.toString());
      }
    }
    await cacheFactory.validateCache(validNames);
  }

  ///return addObjects
  Future<void> _loadNewMapObjects(
      Set<MapObject> oldObjects, Set<MapObject> newObjects) async {
    final mapObjectUpdates = MapObjectUpdates.from(oldObjects, newObjects);

    _updateMapObjects(mapObjectUpdates.updateObjects);
    await _removeMapObjects(mapObjectUpdates.removeObjects);
    _addMapObjectsInZIndexOrder(mapObjectUpdates.addObjects);
  }

  ///add objects by zIndex ASC order
  Future<void> _addMapObjectsInZIndexOrder(Set<MapObject> mapObjects) async {
    final sortedObjectMap = mapObjects
        .sorted((a, b) => a.zIndex.compareTo(b.zIndex))
        .groupSetsBy((element) => element.zIndex);

    final sortedKeys = sortedObjectMap.keys.sorted((a, b) => a.compareTo(b));

    for (final key in sortedKeys) {
      final sameZIndexObjectSet = sortedObjectMap[key];
      if (sameZIndexObjectSet != null) {
        await _addMapObjects(sameZIndexObjectSet);
      }
    }
  }

  ///don't use this, use [_addMapObjectsInZIndexOrder] instead
  Future<void> _addMapObjects(Set<MapObject> mapObjects) async {
    await Future.wait(mapObjects.map((e) => _addMapObject(e)));
  }

  Future<void> _removeMapObjects(Set<MapObject> mapObjects) async {
    await Future.wait(mapObjects.map((object) => _removeMapObject(object)));
  }

  Future<void> _updateMapObjects(Set<MapObject> mapObjects) async {
    await Future.wait(mapObjects.map((object) => _updateMapObject(object)));
  }

  Future<void> _addMapObject(MapObject mapObject) async {
    if (mapObject is Polygon) {
      await _addPolygon(mapObject);
    } else if (mapObject is Polyline) {
      await _addPolyline(mapObject);
    } else if (mapObject is Circle) {
      await _addCircle(mapObject);
    } else if (mapObject is Marker) {
      await _addMarker(mapObject);
    }
  }

  Future<void> _updateMapObject(MapObject mapObject) async {
    if (mapObject is Polygon) {
      await _updatePolygon(mapObject);
    } else if (mapObject is Polyline) {
      await _updatePolyline(mapObject);
    } else if (mapObject is Circle) {
      await _updateCircle(mapObject);
    } else if (mapObject is Marker) {
      await _updateMarker(mapObject);
    }
  }

  Future<void> _removeMapObject(MapObject mapObject) async {
    if (mapObject is Polygon) {
      await _removePolygon(mapObject.id.value);
    } else if (mapObject is Polyline) {
      await _removePolyline(mapObject.id.value);
    } else if (mapObject is Circle) {
      await _removeCircle(mapObject.id.value);
    } else if (mapObject is Marker) {
      await _removeMarker(mapObject.id.value);
    }
  }

  Future<void> _addPolygon(Polygon polygon) async {
    if (_viettelPolygonMap.containsKey(polygon.id.value)) {
      return;
    }

    //add a dummy object to map
    _viettelPolygonMap.putIfAbsent(
        polygon.id.value,
        () => ViettelPolygon(
            polygon.id.value, vt.Fill("dummy", const vt.FillOptions()), []));

    final fill = await _controller.addFill(polygon.toFillOptions());

    List<vt.Line> outlines = await Future.wait(
        polygon.getOutlineLineOptions().map((e) => _controller.addLine(e)));

    _viettelPolygonMap.update(polygon.id.value,
        (_) => ViettelPolygon(polygon.id.value, fill, outlines));
  }

  Future<void> _removePolygon(String polygonId) async {
    if (_viettelPolygonMap.containsKey(polygonId)) {
      final polygon = _viettelPolygonMap[polygonId];

      if (polygon != null) {
        _controller.removeFill(polygon.fill);

        for (final outline in polygon.outlines) {
          _controller.removeLine(outline);
        }

        _viettelPolygonMap.removeWhere((key, value) => key == polygonId);
      }
    }
  }

  Future<void> _updatePolygon(Polygon polygon) async {
    ViettelPolygon? updatingPolygon = _viettelPolygonMap[polygon.id.value];
    if (updatingPolygon == null) {
      return;
    }

    _controller.updateFill(updatingPolygon.fill, polygon.toFillOptions());

    List<vt.Line> lines = updatingPolygon.outlines;
    await Future.wait(lines.map((e) => _controller.removeLine(e)));
    List<vt.Line> newLines = await Future.wait(
        polygon.getOutlineLineOptions().map((e) => _controller.addLine(e)));

    _viettelPolygonMap.update(
        polygon.id.value,
        (_) =>
            ViettelPolygon(polygon.id.value, updatingPolygon.fill, newLines));
  }

  Future<void> _addPolyline(Polyline polyline) async {
    if (_viettelPolylineMap.containsKey(polyline.id.value)) {
      return;
    }

    //add a dummy object to map
    _viettelPolylineMap.putIfAbsent(
        polyline.id.value, () => vt.Line("dummy", const vt.LineOptions()));
    final line = await _controller.addLine(polyline.toLineOptions());

    _viettelPolylineMap.update(polyline.id.value, (_) => line);
  }

  Future<void> _removePolyline(String polylineId) async {
    if (_viettelPolylineMap.containsKey(polylineId)) {
      final line = _viettelPolylineMap[polylineId];

      if (line != null) {
        _controller.removeLine(line);

        _viettelPolylineMap.removeWhere((key, value) => key == polylineId);
      }
    }
  }

  Future<void> _updatePolyline(Polyline polyline) async {
    vt.Line? updatingPolyline = _viettelPolylineMap[polyline.id.value];
    if (updatingPolyline == null) {
      return;
    }

    _controller.updateLine(updatingPolyline, polyline.toLineOptions());
  }

  Future<void> _addCircle(Circle circle) async {
    if (_viettelCircleMap.containsKey(circle.id.value)) {
      return;
    }

    //add a dummy object to map
    _viettelCircleMap.putIfAbsent(
        circle.id.value,
        () => ViettelCircle(
            circle.id.value,
            vt.Fill("dummy", const vt.FillOptions()),
            vt.Line("dummy", const vt.LineOptions())));

    List<LatLng> points = circle.toCirclePoints();

    final fill = await _controller.addFill(circle.toFillOptions(points));
    final outline = await _controller.addLine(circle.toLineOptions(points));

    _viettelCircleMap.update(
        circle.id.value, (_) => ViettelCircle(circle.id.value, fill, outline));
  }

  Future<void> _removeCircle(String circleId) async {
    if (_viettelCircleMap.containsKey(circleId)) {
      final circle = _viettelCircleMap[circleId];

      if (circle != null) {
        _controller.removeFill(circle.fill);
        _controller.removeLine(circle.outline);

        _viettelCircleMap.removeWhere((key, value) => key == circleId);
      }
    }
  }

  Future<void> _updateCircle(Circle circle) async {
    ViettelCircle? updatingCircle = _viettelCircleMap[circle.id.value];
    if (updatingCircle == null) {
      return;
    }

    List<LatLng> points = circle.toCirclePoints();

    _controller.updateFill(updatingCircle.fill, circle.toFillOptions(points));
    _controller.updateLine(
        updatingCircle.outline, circle.toLineOptions(points));
  }

  Future<void> _addMarker(Marker marker) async {
    if (_viettelMarkerMap.containsKey(marker.id.value)) {
      return;
    }

    //add a dummy object to map
    _viettelMarkerMap.putIfAbsent(
        marker.id.value, () => vt.Symbol("dummy", const vt.SymbolOptions()));

    //marker resource must has been initialized before being added to the map
    await _tryAddMarkerIconData(marker);

    final symbol = await _controller.addSymbol(marker.toSymbolOptions());

    _viettelMarkerMap.update(marker.id.value, (_) => symbol);
  }

  Future<void> _removeMarker(String markerId) async {
    if (_viettelMarkerMap.containsKey(markerId)) {
      final marker = _viettelMarkerMap[markerId];

      if (marker != null) {
        _controller.removeSymbol(marker);

        _viettelMarkerMap.removeWhere((key, value) => key == markerId);
      }
    }
  }

  Future<void> _updateMarker(Marker marker) async {
    vt.Symbol? updatingMarker = _viettelMarkerMap[marker.id.value];
    if (updatingMarker == null) {
      return;
    }

    await _tryAddMarkerIconData(marker);

    _controller.updateSymbol(updatingMarker, marker.toSymbolOptions());
  }


  Future<void> _tryAddMarkerIconData(Marker marker) async {
    if (!_addedMarkerIconNames.contains(marker.icon.data.name)) {
      _addedMarkerIconNames.add(marker.icon.data.name);
      Uint8List bitmap =
          await marker.icon.data.initResource(markerIconDataProcessor);
      _controller.addImage(marker.icon.data.name, bitmap);
    }
  }

  Future<void> _removeOldIconData() async {
    final markers = _originalShapes.markers;
  }

  @override
  void onDispose() {
    _controller.dispose();
  }

  Future<void> onStyleLoaded(CoreMapShapes shapes) async {
    _styleLoaded = true;
    loadNewShapes(shapes);
  }

  @override
  CameraPosition getCurrentPosition() {
    return _controller.cameraPosition?.toCore() ?? _initialCameraPosition;
  }

  void _initHandlers() {
    _initCameraMoveHandler();
    _initMarkerTapHandler();
    _initPolygonTapHandler();
    _initCircleTapHandler();
    _initPolylineTapHandler();
  }

  void _initCameraMoveHandler() {
    if (callbacks?.onCameraMove != null) {
      _controller.addListener(() {
        if (_controller.isCameraMoving) {
          _onCameraMove(_controller.cameraPosition);
        }
      });
    }
  }

  void _initMarkerTapHandler() {
    _controller.onSymbolTapped.add((vtSymbol) {
      String? markerId =
          _viettelMarkerMap.keyWhere((value) => value.id == vtSymbol.id);
      final marker = _originalShapes.markers
          .firstWhereOrNull((element) => element.id.value == markerId);
      if (marker != null) {
        if (marker.onTap != null) {
          marker.onTap?.call();
        } else {
          _defaultMarkerOnTap(marker);
        }
      }
    });
  }

  void _initCircleTapHandler() {
    void callCircleTapById(String? id) {
      final circle = _originalShapes.circles
          .firstWhereOrNull((element) => element.id.value == id);
      circle?.onTap?.call();
    }

    //check if polygon's outlines are tapped?
    _controller.onLineTapped.add((vtLine) {
      String? circleId = _viettelCircleMap
          .keyWhere((vtCircle) => vtCircle.outline.id == vtLine.id);

      callCircleTapById(circleId);
    });

    //check if the fill is tapped?
    _controller.onFillTapped.add((fill) {
      String? circleId =
          _viettelCircleMap.keyWhere((value) => value.fill.id == fill.id);

      callCircleTapById(circleId);
    });
  }

  void _initPolylineTapHandler() {
    _controller.onLineTapped.add((vtLine) {
      String? polylineId =
          _viettelPolylineMap.keyWhere((value) => value.id == vtLine.id);
      final polyline = _originalShapes.polylines
          .firstWhereOrNull((element) => element.id.value == polylineId);
      polyline?.onTap?.call();
    });
  }

  void _initPolygonTapHandler() {
    void callPolygonOnTapById(String? id) {
      final polygon = _originalShapes.polygons
          .firstWhereOrNull((element) => element.id.value == id);
      polygon?.onTap?.call();
    }

    //check if polygon's outlines are tapped?
    _controller.onLineTapped.add((vtLine) {
      String? polygonId = _viettelPolygonMap.keyWhere((vtPolygon) =>
          vtPolygon.outlines
              .firstWhereOrNull((outline) => outline.id == vtLine.id) !=
          null);

      callPolygonOnTapById(polygonId);
    });

    //check if the fill is tapped?
    _controller.onFillTapped.add((fill) {
      String? polygonId =
          _viettelPolygonMap.keyWhere((value) => value.fill.id == fill.id);

      callPolygonOnTapById(polygonId);
    });
  }

  void _onCameraMove(vt.CameraPosition? position) {
    if (position != null) {
      callbacks?.onCameraMove?.call(position.toCore());
    }
  }

  void onCameraMovingStarted() {
    callbacks?.onCameraMoveStarted?.call();
  }

  void onCameraIdle() {
    callbacks?.onCameraIdle?.call();
  }

  void onMapClick(vt.LatLng latLng) {
    callbacks?.onTap?.call(latLng.toCore());
  }

  void onMapLongClick(vt.LatLng latLng) {
    callbacks?.onLongPress?.call(latLng.toCore());
  }

  @override
  Future<ScreenCoordinate> getScreenCoordinate(LatLng latLng) async {
    return (await _controller.toScreenLocation(latLng.toViettel()))
        .toScreenCoordinate();
  }

  @override
  Future<LatLng> getLatLng(ScreenCoordinate screenCoordinate) async {
    return (await _controller.toLatLng(screenCoordinate.toPoint())).toCore();
  }

  void _defaultMarkerOnTap(Marker marker) {
    animateCamera(CameraUpdate.newLatLng(marker.position), duration: 1);
    onMarkerTapSetInfoWindow(marker.id);
  }

  @override
  Future<void> animateCamera(CameraUpdate cameraUpdate, {int? duration}) async {
    await _controller.animateCamera(cameraUpdate: cameraUpdate.toViettel(), duration: duration);
  }

  @override
  Future<void> moveCamera(CameraUpdate cameraUpdate) async {
    await _controller.moveCamera(cameraUpdate.toViettel());
  }

  @override
  Future<void> hideInfoWindow(MarkerId markerId) => infoWindowManager.hideInfoWindow(markerId);

  @override
  Future<void> showInfoWindow(MarkerId markerId) => infoWindowManager.showInfoWindow(markerId);

  @override
  void onMarkerTapSetInfoWindow(MarkerId markerId) => infoWindowManager.onMarkerTapSetInfoWindow(markerId);
}
