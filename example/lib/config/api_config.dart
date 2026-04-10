class ApiConfig {
  static const String googleKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  @Deprecated('Viettel map support has been removed.')
  static const String viettelKey = "";

  static void validateKeys() {
    if (googleKey.isEmpty) {
      throw StateError(
        'Missing API key. Pass --dart-define=GOOGLE_MAPS_API_KEY=... when running the example app.',
      );
    }
  }
}
