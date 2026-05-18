class ApiConfig {
  static const String googleKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  static const String viettelKey = String.fromEnvironment(
    'VIETTEL_MAPS_API_KEY',
    defaultValue: '',
  );

  static void validateKeys() {
    if (googleKey.isEmpty) {
      throw StateError(
        'Missing API key. Pass --dart-define=GOOGLE_MAPS_API_KEY=... when running the example app.',
      );
    }
  }
}
