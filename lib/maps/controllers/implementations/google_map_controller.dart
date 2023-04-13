part of core_map;

class _GoogleMapController extends BaseCoreMapController
    with ChangeNotifier {

  @override
  CoreMapType get coreMapType => CoreMapType.google;

  final gg.GoogleMapController _controller;

  gg.CameraPosition _currentCameraPosition;

  final MarkerIconDataProcessor markerIconDataProcessor;

  _GoogleMapController(this._controller, {
    required CoreMapData data,
    CoreMapCallbacks? callbacks,
    required this.markerIconDataProcessor,
  }):_currentCameraPosition = data.initialCameraPosition.toGoogle(), super(callbacks);
  @override
  void onDispose() {
    dispose();
    _controller.dispose();
  }

  @override
  CameraPosition getCurrentPosition() {
    return _currentCameraPosition.toCore();
  }

  void onCameraMove(gg.CameraPosition position) {
    _currentCameraPosition = position;

    callbacks?.onCameraMove?.call(position.toCore());
  }

  @override
  Future<ScreenCoordinate> getScreenCoordinate(LatLng latLng) async {
    return (await _controller.getScreenCoordinate(latLng.toGoogle())).toCore();
  }

  @override
  Future<LatLng> getLatLng(ScreenCoordinate screenCoordinate) async {
    return (await _controller.getLatLng(screenCoordinate.toGoogle())).toCore();
  }

  @override
  Future<void> animateCamera(CameraUpdate cameraUpdate) async {
    await _controller.animateCamera(cameraUpdate.toGoogle());
  }

  Future<void> updateMarkers(Set<Marker> newMarkers) async {
    List<Future> markerFutures = [];
    for (final marker in newMarkers) {
      //process all marker data to check if there are new maker icons
      markerFutures.add(marker.icon.data.initResource(markerIconDataProcessor));
    }
    await Future.wait(markerFutures);

    notifyListeners();
  }
}