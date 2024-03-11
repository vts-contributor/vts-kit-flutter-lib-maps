part of core_map;

class CoreMap extends StatefulWidget {
  final CoreMapType type;

  final CoreMapData data;

  final CoreMapShapes? shapes;

  final CoreMapCallbacks? callbacks;

  final CoreMapCustoms? custom;

  const CoreMap({
    super.key,
    this.type = CoreMapType.viettel,
    this.callbacks,
    required this.data,
    this.shapes,
      this.custom
  });

  @override
  State<CoreMap> createState() => _CoreMapState();
}

class _CoreMapState extends State<CoreMap> with WidgetsBindingObserver {
  CoreMapControllerWrapper? _controller;
  CoreMapController? _fullScreenController;
  CoreMapController? _normalController;

  late final _LocationManager _locationManager = _LocationManager(widget.callbacks);

  late final _RoutingManagerImpl _routingManager = _RoutingManagerImpl(_locationManager);

  late final _InfoWindowManagerImpl _infoWindowManager = _InfoWindowManagerImpl(widget.shapes?.markers, _markerIconDataFactory);

  final MarkerIconDataFactory _markerIconDataFactory = MarkerIconDataFactory();

  late final _ClusterManagerImpl _clusterManager = _ClusterManagerImpl(
    widget.shapes?.markers,
    widget.custom?.clusterManager,
  );

  bool _isFullScreen = false;

  OverlayEntry? _mapOverlay;

  double zoomLevel = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initLocationManager();
    _initRoutingManager();
    _initInfoWindowManager();
    _initClusterManager();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _locationManager.dispose();
    _routingManager.dispose();
  }

  void _initLocationManager() {
    _locationManager.addListener(() {
      Log.d("CoreMap location manager", "rebuilding");
      setState(() {});
    });

    _locationManager.enabled = widget.data.myLocationEnabled;
  }

  void _initRoutingManager() {
    _routingManager.addListener(() => setState(() {}));
    _updateRoutingManager();
  }

  void _initInfoWindowManager() {
    _infoWindowManager.addListener(() {
      Log.d("CoreMap location manager", "rebuilding");
      setState(() {});
    });
  }

  void _initClusterManager() {
    _clusterManager.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant CoreMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    _updateLocationManager();
    _updateRoutingManager();
    _updateInfoWindowManager();
    _updateClusterManager();
  }

  void _updateLocationManager() {
    _locationManager.updateCallbacks(widget.callbacks);
    _locationManager.enabled = widget.data.myLocationEnabled;
  }

  void _updateRoutingManager() {
    _routingManager.updateColor(widget.data.selectedRouteColor, widget.data.unselectedRouteColor);
    _routingManager.updateWidth(widget.data.selectedRouteWidth, widget.data.unselectedRouteWidth);
    _routingManager.updateDefaultTravelMode(widget.data.defaultTravelMode);
    _routingManager.token = widget.data.accessToken;
  }

  void _updateInfoWindowManager() {
    _infoWindowManager.updateMarkers(widget.shapes?.markers);
  }

  void _updateClusterManager() {
    if (widget.data.isUseCluster) {
      _clusterManager._updateMarkers(widget.shapes?.markers);
      _clusterManager
          ._updateCustomClusterManager(widget.custom?.clusterManager);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _locationManager.updateOnWidgetResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: [
        _buildMapFullParams(),
        ..._buildButtons(context),
        ..._infoWindowManager.getInfoWindows(context),
      ],
    );
  }

  Widget _buildMapFullParams() {
    return _buildMap(
        type: widget.type,
        data: widget.data.copyWith(
            initialCameraPosition:
            _controller?.getCurrentPosition() ?? widget.data.initialCameraPosition),
        shapes: _routingManager.combineShape(
          widget.data.isUseCluster
              ? _clusterManager._filterCluster(widget.shapes)
              : widget.shapes,
        ),
        callbacks: (widget.callbacks ?? CoreMapCallbacks()).copyWith(
            onMapCreated: (controller) {
              CoreMapControllerWrapper controllerWrapper = (_controller ??= CoreMapControllerWrapper());
              if (_isFullScreen) {
                _fullScreenController = controller;
              } else {
                _normalController = controller;
              }
              controllerWrapper.innerController = controller;

              widget.callbacks?.onMapCreated?.call(controllerWrapper);

              _locationManager.notifyRebuildUserLocationMapObject();

              _infoWindowManager.updateController(controllerWrapper);
              _routingManager.mapController = controllerWrapper;

              if (widget.data.isUseCluster) {
                _clusterManager.mapController = controllerWrapper;
              }

              widget.callbacks?.onRoutingManagerReady?.call(_routingManager);
            },
            onCameraMove: (pos) {
              widget.callbacks?.onCameraMove?.call(pos);

              _infoWindowManager.notifyCameraMove();

            zoomLevel = pos.zoom;
          },
          onCameraIdle: () {
            if (widget.data.isUseCluster) {
              _clusterManager.notifyCameraIdle(
                  zoomLevel, widget.shapes?.markers);
            }
          },
        )
    );
  }

  Widget _buildMap({
    required CoreMapType type,
    required CoreMapData data,
    required CoreMapShapes shapes,
    CoreMapCallbacks? callbacks,
  }) {
    switch (type) {
      case CoreMapType.google:
        return _CoreGoogleMap(
          data: data,
          callbacks: callbacks,
          shapes: shapes,
          markerIconDataFactory: _markerIconDataFactory,
          infoWindowManager: _infoWindowManager,
        );
      case CoreMapType.viettel:
        return _CoreViettelMap(
          data: data,
          callbacks: callbacks,
          userLocationDrawOptions:
              getViettelUserLocationDrawOptions(_locationManager._userLocation),
          shapes: shapes,
          markerIconDataFactory: _markerIconDataFactory,
          infoWindowManager: _infoWindowManager,
        );
    }
  }

  ///for pseudo user location icon on the vt map because currently, vt map's
  ///location feature is broken
  vt.CircleOptions? getViettelUserLocationDrawOptions(Position? userLocation) {
    double? lat = userLocation?.latitude;
    double? lng = userLocation?.longitude;

    if (lat != null && lng != null) {
      return vt.CircleOptions(
        geometry: LatLng(lat, lng).toViettel(),
        circleRadius: 5,
        circleColor: Colors.blue.toHex(),
        circleStrokeColor: Colors.white.toHex(),
        circleStrokeWidth: 1,
      );
    } else {
      return null;
    }
  }

  double _getAvoidZoomButtonHorizontalPadding(Alignment buttonAlignment, EdgeInsets zoomButtonPadding) {
    return widget.data.zoomButtonEnabled && buttonAlignment == widget.data.zoomButtonAlignment
        ? zoomButtonPadding.horizontal + Constant.buttonDistance + Constant.zoomButtonSize: Constant.defaultButtonPadding;
  }

  List<Widget> _buildButtons(BuildContext context) {
    bool hasLocationButton = widget.data.myLocationEnabled && widget.data.myLocationEnabled;
    bool hasZoomButton = widget.data.zoomButtonEnabled;
    bool hasFullScreenButton = widget.data.fullScreenButtonEnabled;

    EdgeInsets zoomButtonPadding = hasZoomButton
        ? (widget.data.zoomButtonPadding ?? const EdgeInsets.all(Constant.defaultButtonPadding))
        : EdgeInsets.zero;

    double locationButtonPaddingHorizontal = _getAvoidZoomButtonHorizontalPadding(
        widget.data.myLocationButtonAlignment, zoomButtonPadding);

    EdgeInsets locationButtonPadding = widget.data.myLocationButtonPadding ??
        EdgeInsets.symmetric(
            horizontal: locationButtonPaddingHorizontal, vertical: Constant.defaultButtonPadding);

    double fullScreenButtonPaddingSizeHorizontal = _getAvoidZoomButtonHorizontalPadding(
        widget.data.fullScreenButtonAlignment, zoomButtonPadding);
    double fullScreenButtonPaddingSizeVertical = widget.data.myLocationButtonEnabled &&
        widget.data.myLocationButtonAlignment == widget.data.fullScreenButtonAlignment?
        locationButtonPadding.vertical + Constant.buttonDistance + Constant.myLocationButtonSize:
        Constant.defaultButtonPadding;

    EdgeInsets fullScreenButtonPadding = widget.data.fullScreenButtonPadding ??
        EdgeInsets.symmetric(
            horizontal: fullScreenButtonPaddingSizeHorizontal, vertical: fullScreenButtonPaddingSizeVertical);

    return [
      if (hasFullScreenButton)
        Align(
          alignment: widget.data.fullScreenButtonAlignment,
          child: Padding(
            padding: fullScreenButtonPadding,
            child: _buildFullScreenButton(context),
          ),
        ),
      if (hasLocationButton)
        Align(
          alignment: widget.data.myLocationButtonAlignment,
          child: Padding(
            padding: locationButtonPadding,
            child: _buildUserLocationButton(context),
          ),
        ),
      if (hasZoomButton)
        Align(
          alignment: widget.data.zoomButtonAlignment,
          child: Padding(
            padding: zoomButtonPadding,
            child: _buildZoomButtons(context),
          ),
        ),
    ];
  }

  Widget _buildUserLocationButton(BuildContext context) {
    const buttonSize = Constant.myLocationButtonSize;

    return _buildButton(context,
      icon: Icons.my_location_outlined,
      buttonSize: buttonSize,
      onTap: () async {
        double zoom = 17;
        double? lat = _locationManager._userLocation?.latitude;
        double? lng = _locationManager._userLocation?.longitude;
        if (lat != null && lng != null) {
          _controller?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), zoom));
        } else {
          try {
            Position position = await Geolocator.getCurrentPosition(timeLimit: const Duration(seconds: 10));
            _locationManager._updateUserLocation(position);
            _controller?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(position.latitude, position.longitude), zoom));
          } catch (e, s) {
            debugPrint(e.toString());
            debugPrintStack(stackTrace: s);
          }
        }
      },
    );
  }

  Widget _buildZoomButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildZoomButton(context, true),
        _buildDivider(context),
        _buildZoomButton(context, false),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    double width = min(widget.data.zoomInButtonData?.width ?? Constant.zoomButtonSize,
        widget.data.zoomOutButtonData?.width ?? Constant.zoomButtonSize);
    return Container(
      width: width,
      height: widget.data.zoomButtonDividerThickness,
      color: widget.data.zoomButtonDividerColor,
    );
  }

  Widget _buildZoomButton(BuildContext context, bool zoomIn) {
    double buttonSize = Constant.zoomButtonSize;
    CameraUpdate cameraUpdate = zoomIn ? CameraUpdate.zoomIn() : CameraUpdate.zoomOut();
    CoreMapButtonCustomizeData? buttonData =
        zoomIn ? widget.data.zoomInButtonData : widget.data.zoomOutButtonData;
    return _buildButton(context,
      buttonData: buttonData,
      onTap: () async {
        await _controller?.animateCamera(cameraUpdate);
      },
      icon: zoomIn ? Icons.add : Icons.remove,
      buttonSize: buttonSize,
    );
  }

  Widget _buildButton(BuildContext context, {
    CoreMapButtonCustomizeData? buttonData,
    void Function()? onTap,
    double? buttonSize,
    Color? buttonColor,
    required IconData icon,
    Color? buttonIconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          height: buttonData?.height ?? buttonSize,
          width: buttonData?.width ?? buttonSize,
          decoration: BoxDecoration(
            color: buttonData?.color ?? buttonColor ?? Constant.defaultButtonColor,
            borderRadius: buttonData?.borderRadius,
            border: Border.fromBorderSide(buttonData?.borderSide ?? BorderSide.none),
          ),
          child: buttonData?.icon ??
              Icon(
                icon,
                color: buttonIconColor ?? Constant.defaultButtonIconColor,
              ),
        ),
      ),
    );
  }

  Widget _buildFullScreenButton(BuildContext context) {
    return _buildButton(context,
      onTap: () {
        bool wasFullScreen = _isFullScreen;
        _isFullScreen = !_isFullScreen;
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: wasFullScreen? SystemUiOverlay.values: []);

        CoreMapController? controller;
        controller = wasFullScreen? _normalController: _fullScreenController;
        if (controller != null) {
          _controller?.innerController = controller;
        }

        if (wasFullScreen) {
          _mapOverlay?.remove();
          _mapOverlay = null;

          CameraPosition? newCameraPosition = _fullScreenController?.getCurrentPosition();
          if (newCameraPosition != null) {
            _normalController?.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition), duration: 1);
          }

          _fullScreenController = null;

          setState(() {
          });
        } else {
          _openMapFullScreen(context);
        }
      },
      buttonData: widget.data.fullScreenButtonData,
      buttonSize: Constant.fullScreenButtonSize,
      icon: _isFullScreen? Icons.fullscreen_exit: Icons.fullscreen,
    );
  }

  void _openMapFullScreen(BuildContext context) {
    OverlayEntry overlayEntry = OverlayEntry(builder: (context) {
      return build(context);
    });
    _mapOverlay = overlayEntry;
    Overlay.of(context).insert(
      overlayEntry,
    );
  }
}
