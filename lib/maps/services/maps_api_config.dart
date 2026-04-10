
class MapAPIConfig {
  final String mapsHost;
  final String placeHost;
  final String routeHost;
  final String geocodePath;
  final String placeDetailPath;
  final String autocompleteSearchPath;
  final String nearbySearchPath;
  final String directionPath;
  final String distanceMatrixPath;
  final String provider;
  String? key;

  String hostOf(String path) {
    if (path == geocodePath || path == nearbySearchPath) {
      // Legacy API
      return mapsHost;
    } else if (path == placeDetailPath || path == autocompleteSearchPath) {
      // New Place API
      return placeHost;
    } else if (path == directionPath || path == distanceMatrixPath) {
      return routeHost;
    }
    return mapsHost;
  }

  MapAPIConfig({
    required this.mapsHost,
    required this.placeHost,
    required this.routeHost,
    required this.geocodePath,
    required this.placeDetailPath,
    required this.autocompleteSearchPath,
    required this.nearbySearchPath,
    required this.directionPath,
    required this.distanceMatrixPath,
    required this.provider,
    this.key,
  });

  static MapAPIConfig getConfig(String provider) {
    // Both Google and legacy Viettel now use Google Maps infrastructure
    return MapAPIConfig(
      mapsHost: 'https://maps.googleapis.com/maps/api',
      placeHost: 'https://places.googleapis.com/v1', // Place API New
      routeHost: 'https://maps.googleapis.com/maps/api',
      geocodePath: 'geocode/json',
      placeDetailPath: 'places', // Place API New
      autocompleteSearchPath: 'places:autocomplete', // Place API New
      nearbySearchPath: 'place/nearbysearch/json', // Place API Legacy
      directionPath: 'directions/json',
      distanceMatrixPath: 'distancematrix/json',
      provider: provider,
    );
  }
}

extension MapAPIConfigExtension on MapAPIConfig {
  static MapAPIConfig customConfig({
    required String provider,
    String? mapsHost,
    String? placeHost,
    String? routeHost,
    String? geocodePath,
    String? placeDetailPath,
    String? autocompleteSearchPath,
    String? nearbySearchPath,
    String? directionPath,
    String? distanceMatrixPath,
    String? key,
    Map<String, String>? pathToHost,
  }) {
    final baseConfig = MapAPIConfig.getConfig(provider);

    return _CustomMapAPIConfig(
      mapsHost: mapsHost ?? baseConfig.mapsHost,
      placeHost: placeHost ?? baseConfig.placeHost,
      routeHost: routeHost ?? baseConfig.routeHost,
      geocodePath: geocodePath ?? baseConfig.geocodePath,
      placeDetailPath: placeDetailPath ?? baseConfig.placeDetailPath,
      autocompleteSearchPath: autocompleteSearchPath ?? baseConfig.autocompleteSearchPath,
      nearbySearchPath: nearbySearchPath ?? baseConfig.nearbySearchPath,
      directionPath: directionPath ?? baseConfig.directionPath,
      distanceMatrixPath: distanceMatrixPath ?? baseConfig.distanceMatrixPath,
      provider: provider,
      key: key ?? baseConfig.key,
      pathToHost: pathToHost,
    );
  }
}

class _CustomMapAPIConfig extends MapAPIConfig {
  final Map<String, String>? pathToHost;

  _CustomMapAPIConfig({
    required super.mapsHost,
    required super.placeHost,
    required super.routeHost,
    required super.geocodePath,
    required super.placeDetailPath,
    required super.autocompleteSearchPath,
    required super.nearbySearchPath,
    required super.directionPath,
    required super.distanceMatrixPath,
    required super.provider,
    super.key,
    this.pathToHost,
  });

  @override
  String hostOf(String path) {
    return pathToHost?[path] ?? super.hostOf(path);
  }
}
