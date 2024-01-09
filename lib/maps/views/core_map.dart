part of core_map;

class CoreMap extends StatefulWidget {
  final CoreMapType type;

  final CoreMapData data;

  final CoreMapShapes? shapes;

  final CoreMapCallbacks? callbacks;

  const CoreMap({
    super.key,
    this.type = CoreMapType.viettel,
    this.callbacks,
    required this.data,
    this.shapes,
  });

  @override
  State<CoreMap> createState() => _CoreMapState();
}

class _CoreMapState extends State<CoreMap> with WidgetsBindingObserver {
  CoreMapController? _controller;

  late final _LocationManager _locationManager = _LocationManager(widget.callbacks);

  late final _RoutingManagerImpl _routingManager = _RoutingManagerImpl(_locationManager);

  late final _InfoWindowManagerImpl _infoWindowManager = _InfoWindowManagerImpl(widget.shapes?.markers, _markerIconDataFactory);

  final MarkerIconDataFactory _markerIconDataFactory = MarkerIconDataFactory();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initLocationManager();
    _initRoutingManager();
    _initInfoWindowManager();
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

  @override
  void didUpdateWidget(covariant CoreMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    _updateLocationManager();
    _updateRoutingManager();
    _updateInfoWindowManager();
  }

  void _updateLocationManager() {
    _locationManager.updateCallbacks(widget.callbacks);
    _locationManager.enabled = widget.data.myLocationEnabled;
  }

  void _updateRoutingManager() {
    _routingManager.updateColor(widget.data.selectedRouteColor, widget.data.unselectedRouteColor);
    _routingManager.updateWidth(widget.data.selectedRouteWidth, widget.data.unselectedRouteWidth);
    _routingManager.token = widget.data.accessToken;
  }

  void _updateInfoWindowManager() {
    _infoWindowManager.updateMarkers(widget.shapes?.markers);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _locationManager.updateOnWidgetResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    CoreMapCallbacks callbacks = widget.callbacks ?? CoreMapCallbacks();

    return Stack(
      fit: StackFit.loose,
      children: [
        _buildMap(
          type: widget.type,
          data: widget.data.copyWith(
              initialCameraPosition:
                  _controller?.getCurrentPosition() ?? widget.data.initialCameraPosition),
          shapes: _routingManager.combineShape(widget.shapes),
          callbacks: callbacks.copyWith(
            onMapCreated: (controller) {
            _controller = controller;
            widget.callbacks?.onMapCreated?.call(controller);

            _locationManager.notifyRebuildUserLocationMapObject();

            _infoWindowManager.updateController(controller);
            _routingManager.mapController = controller;

            widget.callbacks?.onRoutingManagerReady?.call(_routingManager);
          },
            onCameraMove: (pos) {
            widget.callbacks?.onCameraMove?.call(pos);

            _infoWindowManager.notifyCameraMove();
          }
          ),
        ),
        ..._buildButtons(context),
        ..._infoWindowManager.getInfoWindows(context),
      ],
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
  vt.CircleOptions? getViettelUserLocationDrawOptions(LocationData? userLocation) {
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

  List<Widget> _buildButtons(BuildContext context) {
    bool hasLocationButton = widget.data.myLocationEnabled && widget.data.myLocationEnabled;
    bool hasZoomButton = widget.data.zoomButtonEnabled;

    EdgeInsets zoomButtonPadding = hasZoomButton
        ? (widget.data.zoomButtonPadding ?? const EdgeInsets.all(Constant.defaultButtonPadding))
        : EdgeInsets.zero;

    double locationButtonPaddingSize =
        hasZoomButton && widget.data.myLocationButtonAlignment == widget.data.zoomButtonAlignment
        ? zoomButtonPadding.horizontal + Constant.buttonDistance + Constant.zoomButtonSize
        : Constant.defaultButtonPadding;
    EdgeInsets locationButtonPadding = widget.data.myLocationButtonPadding ??
        EdgeInsets.symmetric(
            horizontal: locationButtonPaddingSize, vertical: Constant.defaultButtonPadding);

    return [
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          double? lat = _locationManager._userLocation?.latitude;
          double? lng = _locationManager._userLocation?.longitude;
          if (lat != null && lng != null) {
            double zoom = 17;
            _controller?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), zoom));
          }
        },
        child: Ink(
          height: widget.data.myLocationButtonData?.height ?? buttonSize,
          width: widget.data.myLocationButtonData?.width ?? buttonSize,
          decoration: BoxDecoration(
            color: widget.data.myLocationButtonData?.color ?? Colors.white.withOpacity(0.5),
            borderRadius: widget.data.myLocationButtonData?.borderRadius,
            border: Border.fromBorderSide(widget.data.myLocationButtonData?.borderSide ?? BorderSide.none),
          ),
          child: Center(
            child: widget.data.myLocationButtonData?.icon ??
                Icon(
                  Icons.my_location_outlined,
                  color: Colors.black.withOpacity(0.6),
                ),
          ),
        ),
      ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await _controller?.animateCamera(cameraUpdate);
        },
        child: Ink(
          height: buttonData?.height ?? buttonSize,
          width: buttonData?.width ?? buttonSize,
          decoration: BoxDecoration(
            color: buttonData?.color ?? Colors.white.withOpacity(0.5),
            borderRadius: buttonData?.borderRadius,
            border: Border.fromBorderSide(buttonData?.borderSide ?? BorderSide.none),
          ),
          child: buttonData?.icon ??
              Icon(
                zoomIn ? Icons.add : Icons.remove,
                color: Colors.black.withOpacity(0.6),
              ),
        ),
      ),
    );
  }
}
