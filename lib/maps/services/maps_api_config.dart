
import 'package:maps_core/maps/constants.dart';

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
  String? id;
  String? fingerprint;

  MapAPIConfig copyWithOrReset({
    String? mapsHost,
    String? placeHost,
    String? routeHost,
    String? geocodePath,
    String? placeDetailPath,
    String? autocompleteSearchPath,
    String? nearbySearchPath,
    String? directionPath,
    String? distanceMatrixPath,
    String? provider,
    String? key,
    String? id,
    String? fingerprint,
  }) {
    final defaultConfig = getConfig(this.provider);
    return MapAPIConfig(
      mapsHost: mapsHost == "reset" ? defaultConfig.mapsHost : (mapsHost ?? this.mapsHost),
      placeHost: placeHost == "reset" ? defaultConfig.placeHost : (placeHost ?? this.placeHost),
      routeHost: routeHost == "reset" ? defaultConfig.routeHost : (routeHost ?? this.routeHost),
      geocodePath: geocodePath ?? this.geocodePath,
      placeDetailPath: placeDetailPath ?? this.placeDetailPath,
      autocompleteSearchPath:
          autocompleteSearchPath ?? this.autocompleteSearchPath,
      nearbySearchPath: nearbySearchPath ?? this.nearbySearchPath,
      directionPath: directionPath ?? this.directionPath,
      distanceMatrixPath: distanceMatrixPath ?? this.distanceMatrixPath,
      provider: provider ?? this.provider,
      key: key ?? this.key,
      id: id ?? this.id,
      fingerprint: fingerprint ?? this.fingerprint,
    );
  }

  @override
  String toString() {
    return 'MapAPIConfig{mapsHost: $mapsHost, placeHost: $placeHost, routeHost: $routeHost, geocodePath: $geocodePath, placeDetailPath: $placeDetailPath, autocompleteSearchPath: $autocompleteSearchPath, nearbySearchPath: $nearbySearchPath, directionPath: $directionPath, distanceMatrixPath: $distanceMatrixPath, provider: $provider, key: $key, id: $id, fingerprint: $fingerprint}';
  }

  String hostOf(String path) {
    if (provider == MapProviderConst.GOOGLE) {
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
    } else if (provider == MapProviderConst.VIETTEL) {
      if (path == directionPath || path == distanceMatrixPath) {
        return routeHost;
      } else {
        return placeHost;
      }
    } else {
      throw Exception('Unsupported provider: $provider');
    }
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
    this.id,
    this.fingerprint,
  });

  static MapAPIConfig getConfig(String provider) {
    if (provider == MapProviderConst.GOOGLE) {
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
    } else if (provider == MapProviderConst.VIETTEL) {
      return MapAPIConfig(
        mapsHost: '',
        placeHost: 'https://api-maps.viettel.vn/gateway/placeapi/v4/place-api',
        routeHost: 'https://api-maps.viettel.vn/gateway/routing/v2',
        geocodePath: 'geocode',
        placeDetailPath: 'details',
        autocompleteSearchPath: 'autocomplete',
        nearbySearchPath: 'nearbysearch',
        directionPath: 'directions',
        distanceMatrixPath: 'distancematrix',
        provider: provider,
      );
    } else {
      throw Exception('Unsupported provider: $provider');
    }
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
