library caching;

import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maps_core/maps/models/models.dart';

import '../../extensions/utils.dart';

part 'shared_preferences.dart';

class Profile {
  static bool? _isLogged;
  static int? _loggedUserId;
  static String? _loggedUsername;
  static bool? _useBiometric;
  static Token? _token;
  static User? user;
  static WidgetVisibility? _widgetVisibility;

  static final BehaviorSubject<LatLng> _locationSubject = BehaviorSubject();

  static Stream<LatLng?> get locationStream => _locationSubject.stream;

  static LatLng _lastPosition = LatLng.defaultInvalid();

  static bool get isLogged => _isLogged ?? false;

  static Future<void> setLoggedIn({saveToDisk = true}) async {
    _isLogged = true;
    if (saveToDisk) {
      await _SharedPreferencesCache.saveLogged(true);
    }
  }

  static Future<void> setLoggedOut({saveToDisk = true}) async {
    _isLogged = false;
    if (saveToDisk) {
      await _SharedPreferencesCache.saveLogged(true);
    }
  }

  static Token? get token => isLogged ? _token : null;

  static Future<void> setToken(Token token, {saveToDisk = true}) async {
    _token = token;
    if (saveToDisk) {
      await _SharedPreferencesCache.setToken(token);
    }
  }

  static String? get loggedUsername => isLogged ? _loggedUsername : null;

  static Future<void> setLoggedUsername(String username,
      {saveToDisk = true}) async {
    _loggedUsername = username;
    if (saveToDisk) {
      await _SharedPreferencesCache.setLoggedUsername(username);
    }
  }

  static Future<int?> getLoggedUserId() async {
    _loggedUserId ??= await _SharedPreferencesCache.getLoggedUserId();
    return _loggedUserId;
  }

  static Future<void> setLoggedUserId(int id,
      {saveToDisk = true}) async {
    _loggedUserId = id;
    if (saveToDisk) {
      await _SharedPreferencesCache.setLoggedUserId(id);
    }
  }

  static bool get useBiometric => _useBiometric ?? true;

  static Future<void> setUseBiometric(bool use, {saveToDisk = true}) async {
    _useBiometric = use;
    if (saveToDisk) {
      await _SharedPreferencesCache.setUseBiometric(use);
    }
  }

  static LatLng get lastPosition => _lastPosition;

  static void addLocation(LatLng latLng) {
    _lastPosition = latLng;
    _locationSubject.add(latLng);
  }

  static bool isVisibleWidget(String route, String key, {defaultValue = true}) {
    return _widgetVisibility?.isVisible(route, key,
        defaultValue: defaultValue) ??
        defaultValue;
  }

  static void setWidgetVisibility(WidgetVisibility widgetVisibility) {
    _widgetVisibility = widgetVisibility;
  }

  static Future<void> loadDiskCache() async {
    _isLogged = await _SharedPreferencesCache.isLogged();
    _loggedUsername = await _SharedPreferencesCache.getLoggedUsername();
    _useBiometric = await _SharedPreferencesCache.isUseBiometric();
    _token = await _SharedPreferencesCache.getToken();
  }
}
