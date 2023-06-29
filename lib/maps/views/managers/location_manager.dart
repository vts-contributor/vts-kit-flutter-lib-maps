part of core_map;

///Handle CoreMap Location feature
class _LocationManager extends ChangeNotifier {
  static const String logTag = "LOCATION MANAGER";

  void Function(LocationData userLocation)? _onUserLocationUpdated;

  StreamSubscription<LocationData>? _locationStreamSubscription;

  //customize handle errors
  late Future<bool> Function() _onServiceDisabled;
  late Future<bool> Function() _onPermissionDenied;
  Future<bool> Function()? _onPermissionDeniedForever;

  final Location _location = Location();

  LocationData? _userLocation;

  bool _enabled = false;

  int _updatePrecision = 3;

  ///0 <= value <= 20
  ///
  ///Ex: value == 5:
  ///
  ///9.804382294501336, 105.7186954572177 => 9.80438, 105.71869
  set updatePrecision(int value) {
    if (value >= 0 && value <= 20) {
      _updatePrecision = value;
    }
  }

  _LocationManager(CoreMapCallbacks? callbacks) {
    updateCallbacks(callbacks);
  }

  void updateCallbacks(CoreMapCallbacks? callbacks) {
    _onUserLocationUpdated = callbacks?.onUserLocationUpdated;
    onServiceDisabled = callbacks?.onLocationServiceDisabled;
    onPermissionDenied = callbacks?.onLocationPermissionDenied;
    _onPermissionDeniedForever = callbacks?.onLocationPermissionDeniedForever;
  }

  set onServiceDisabled(Future<bool> Function()? onServiceDisabled) {
    _onServiceDisabled = onServiceDisabled ?? _defaultRequestService;
  }

  set onPermissionDenied(Future<bool> Function()? onPermissionDenied) {
    _onPermissionDenied = onPermissionDenied ?? _defaultRequestPermission;
  }

  set enabled(bool value) {
    if (_enabled == value) {
      return;
    }

    _enabled = value;
    if (_enabled) {
      _validateLocationPermission().then((result) {
        if (result) _enable();
      });
    } else {
      _disable();
    }
  }

  void updateOnWidgetResumed() async {
    //don't call requestPermission here,
    //just checking if user goes to settings and then returns with permission turned on
    if (_enabled && await _locationIsAvailable) {
      _enable();
    }

    //else if disabled: don't have to do anything
    //else if location permission is denied: the same because stream will be cancelled automatically
  }

  Future<bool> _validateLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionStatus;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      return await _onServiceDisabled();
    }

    permissionStatus = await _location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      return await _onPermissionDenied();
    } else if (permissionStatus == PermissionStatus.deniedForever) {
      return await _onPermissionDeniedForever?.call() ?? false;
    }

    return true;
  }

  ///check without asking for permissions
  Future<bool> get _locationIsAvailable async {
    bool serviceEnabled = await _location.serviceEnabled();
    PermissionStatus permissionStatus = await _location.hasPermission();

    return (permissionStatus == PermissionStatus.grantedLimited
        || permissionStatus == PermissionStatus.granted) && serviceEnabled;
  }

  void _startLocationListener() {
    _locationStreamSubscription ??= _location.onLocationChanged.listen((event) {
        // Log.d(logTag, "onLocationChanged ${event.latitude} ${event.longitude}");
        _updateUserLocation(event);
        _onUserLocationUpdated?.call(event);
      })..onError((object, stack) {
        Log.e(logTag, "listen to stream error");
      });
  }

  void _updateUserLocation(LocationData data) {
    _checkRedrawUserLocationOnMap(_userLocation, data);
    _userLocation = data;
  }

  void _checkRedrawUserLocationOnMap(LocationData? oldData, LocationData newData) {
    if (oldData == null) {
      notifyListeners();
      return;
    }

    double? oldLat = oldData.latitude;
    double? oldLng = oldData.longitude;
    double? newLat = newData.latitude;
    double? newLng = newData.longitude;

    if (newLat != null && newLng != null) {
      bool latChanged = false, lngChanged = false;
      if (oldLat != null) {
        latChanged = oldLat.compareAsFixed(newLat, _updatePrecision) != 0;
      }
      if (oldLng != null) {
        lngChanged = oldLng.compareAsFixed(oldLng, _updatePrecision) != 0;
      }

      if (latChanged || lngChanged) {
        notifyListeners();
      }
    } else {
      return;
    }
  }

  void _stopLocationListener() {
    _locationStreamSubscription?.cancel();
  }

  Future<bool> _defaultRequestService() async {
    Log.d(logTag, "Request service");
    return await _location.requestService();
  }

  Future<bool> _defaultRequestPermission() async {
    Log.d(logTag, "Request permission");
    final permissionStatus = await _location.requestPermission();
    return permissionStatus == PermissionStatus.granted ||
        permissionStatus == PermissionStatus.grantedLimited;
  }

  ///Enable listeners. You should check for permission first then call this.
  ///Should ensure that duplication won't happen even if this is called multiple times.
  ///
  /// e.g. check if listener has been registered
  void _enable() async {
    _startLocationListener();
  }

  void _disable() {
    _stopLocationListener();
  }

  void notifyRebuildUserLocationMapObject() {
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();

    _locationStreamSubscription?.cancel();
  }
}
