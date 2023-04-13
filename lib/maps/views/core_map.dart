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

  late final _LocationManager _locationManager =
      _LocationManager(widget.callbacks);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initLocationManager();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _locationManager.dispose();
  }

  void _initLocationManager() {
    _locationManager.addListener(() {
      Log.d("CoreMap location manager", "rebuilding");
      setState(() {});
    });

    _locationManager.enabled = widget.data.myLocationEnabled;
  }

  @override
  void didUpdateWidget(covariant CoreMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    _locationManager.updateCallbacks(widget.callbacks);
    _locationManager.enabled = widget.data.myLocationEnabled;
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
              initialCameraPosition: _controller?.getCurrentPosition() ??
                  widget.data.initialCameraPosition),
          shapes: widget.shapes,
          callbacks: callbacks.copyWith(
            onMapCreated: (controller) {
              _controller = controller;
              widget.callbacks?.onMapCreated?.call(controller);
              _locationManager.notifyRebuildUserLocationMapObject();
            },
          ),
        ),
        if (widget.data.myLocationButtonEnabled && widget.data.myLocationEnabled)
          _buildUserLocationButton(context),
      ],
    );
  }

  Widget _buildMap({
    required CoreMapType type,
    required CoreMapData data,
    CoreMapShapes? shapes,
    CoreMapCallbacks? callbacks,
  }) {
    switch (type) {
      case CoreMapType.google:
        return _CoreGoogleMap(
          data: data,
          callbacks: callbacks,
          shapes: shapes ?? CoreMapShapes(),
        );
      case CoreMapType.viettel:
        return _CoreViettelMap(
            data: data,
            callbacks: callbacks,
            userLocationDrawOptions: getViettelUserLocationDrawOptions(
                _locationManager._userLocation),
            shapes: shapes ?? CoreMapShapes());
    }
  }

  ///for pseudo user location icon on the vt map because currently, vt map's
  ///location feature is broken
  vt.CircleOptions? getViettelUserLocationDrawOptions(
      LocationData? userLocation) {
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

  Widget _buildUserLocationButton(BuildContext context) {
    return Align(
      alignment: widget.data.myLocationButtonAlignment,
      child: SizedBox(
        height: 52,
        width: 52,
        child: Center(
          child: Material(
            color: Colors.white.withOpacity(0.5),
            child: InkWell(
              onTap: () {
                double? lat = _locationManager._userLocation?.latitude;
                double? lng = _locationManager._userLocation?.longitude;
                if (lat != null && lng != null) {
                  _controller?.animateCamera(
                      CameraUpdate.newLatLng(LatLng(lat, lng))
                  );
                }
              },
              child: Ink(
                height: 36,
                width: 36,
                child: Icon(
                  Icons.my_location_outlined,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
