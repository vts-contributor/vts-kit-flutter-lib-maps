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
    if (googleKey.isEmpty && viettelKey.isEmpty) {
      throw StateError(
        'Missing API keys. Pass --dart-define=GOOGLE_MAPS_API_KEY=... '
        'and/or --dart-define=VIETTEL_MAPS_API_KEY=... when running the example app.',
      );
    }
  }
}
