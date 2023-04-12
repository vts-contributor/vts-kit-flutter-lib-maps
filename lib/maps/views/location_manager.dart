part of 'core_map.dart';

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

  _LocationManager(CoreMapCallbacks? callbacks) {
    updateCallbacks(callbacks);
  }

  void updateCallbacks(CoreMapCallbacks? callbacks) {
    _onUserLocationUpdated = callbacks?.onUserLocationUpdated;
    onServiceDisabled = callbacks?.onServiceDisabled;
    onPermissionDenied = callbacks?.onPermissionDenied;
    _onPermissionDeniedForever = callbacks?.onPermissionDeniedForever;
  }

  set onServiceDisabled(Future<bool> Function()? onServiceDisabled) {
    _onServiceDisabled = onServiceDisabled ?? _defaultRequestService;
  }

  set onPermissionDenied(Future<bool> Function()? onPermissionDenied) {
    _onPermissionDenied = onPermissionDenied ?? _defaultRequestPermission;
  }

  bool _enabled = false;

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
        Log.d(logTag, "onLocationChanged ${event.latitude} ${event.longitude}");
        _onUserLocationUpdated?.call(event);
      })..onError((object, stack) {
        Log.e(logTag, "onError");
      });
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
}
