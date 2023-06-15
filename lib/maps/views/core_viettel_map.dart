part of core_map;

class _CoreViettelMap extends StatefulWidget {
  final CoreMapData data;
  final CoreMapCallbacks? callbacks;
  final CoreMapShapes shapes;
  final vt.CircleOptions? userLocationDrawOptions;
  const _CoreViettelMap({Key? key,
    required this.data,
    this.callbacks,
    required this.shapes,
    this.userLocationDrawOptions,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CoreViettelMapState();
}

class _CoreViettelMapState extends State<_CoreViettelMap> {

  _ViettelMapController? _controller;

  final MarkerIconDataFactory _markerIconDataFactory = MarkerIconDataFactory();

  @override
  void didUpdateWidget(covariant _CoreViettelMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    _updateUserLocationDrawOptions();

    _updateCallbacks();

    _updateShapes();
  }

  void _updateCallbacks() {
    _controller?.callbacks = widget.callbacks;
  }

  void _updateShapes() {
    _controller?.loadNewShapes(widget.shapes);
  }

  void _updateUserLocationDrawOptions() {
    _controller?.updateUserLocationShape(widget.userLocationDrawOptions);
  }

  @override
  Widget build(BuildContext context) {
    CoreMapData data = widget.data;
    
    return vt.VTMap(
      accessToken: data.accessToken,
      initialCameraPosition: data.initialCameraPosition.toViettel(),
      gestureRecognizers: widget.data.gestureRecognizers,
      onStyleLoadedCallback: () {
        _ViettelMapController? controller = _controller;
        if (controller != null) {
          controller.onStyleLoaded(widget.shapes);
          controller.updateUserLocationShape(widget.userLocationDrawOptions);
          widget.callbacks?.onMapCreated?.call(controller);
        }
      },
      minMaxZoomPreference: data.minMaxZoomPreference.toViettel(),
      cameraTargetBounds: data.cameraTargetBounds.toViettel(),
      compassEnabled: data.compassEnabled,
      rotateGesturesEnabled: data.rotateGesturesEnabled,
      scrollGesturesEnabled: data.scrollGesturesEnabled,
      zoomGesturesEnabled: data.zoomGesturesEnabled,
      tiltGesturesEnabled: data.tiltGesturesEnabled,

      //WARNING: DON'T TURN ON MY LOCATION OPTIONS HERE. MAP WILL CRASH IN CURRENT VTMAP VERSION
      //DATE: 11/4/2023 - vtmap_gl: ^2.0.4
      myLocationEnabled: false,
      myLocationRenderMode: vt.MyLocationRenderMode.NORMAL,
      myLocationTrackingMode: vt.MyLocationTrackingMode.None,
      gpsControlEnable: false,
      // --------------------------------------------------------

      compassViewPosition: vt.CompassViewPosition.TopLeft,
      onMapCreated: (vt.MapboxMapController mapboxMapController) {
        final controller = _ViettelMapController(mapboxMapController,
          data: data,
          callbacks: widget.callbacks,
          markerIconDataProcessor: _markerIconDataFactory,
          cacheFactory: _markerIconDataFactory,
        );

        _controller = controller;

        //return the controller back to user in onStyleLoaded()
      },
      trackCameraPosition: true,
      onCameraMovingStarted: () {
        _controller?.onCameraMovingStarted();
      },
      onCameraIdle: () {
        _controller?.onCameraIdle();
      },
      onMapClick: (point, coordinate) {
        if (coordinate != null) {
          _controller?.onMapClick(coordinate);
        }
      },
      onMapLongClick: (point, coordinate) {
        if (coordinate != null) {
          _controller?.onMapLongClick(coordinate);
        }
      },
    );
  }
}
