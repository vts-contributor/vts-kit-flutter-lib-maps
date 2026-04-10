import 'package:flutter/material.dart';
import 'package:maps_core/maps/constants.dart';
import 'package:maps_core/maps/extensions/utils.dart';
import 'package:maps_core/maps/utils/provider_resolver.dart';

import '../models/models.dart';
import '../models/network/custom_cancel_token.dart';
import 'maps_api_config.dart';
import 'maps_api_service.dart';

class MapsAPIServiceImpl extends MapsAPIService {
  static MapsAPIServiceImpl? _instance;

  @protected
  @override
  MapsAPIResponseParser jsonParser = MapsAPIResponseParser.link([
    MapsAPIGeocodingParser(),
    MapsAPIAutocompleteSearchParser(),
    MapsAPIPlaceDetailParser(),
    MapsAPIDirectionsParser(),
  ]);

  // Private constructor
  MapsAPIServiceImpl._() : super(MapProviderConst.GOOGLE) {
    configGoogle = MapAPIConfig.getConfig(MapProviderConst.GOOGLE);
    configLegacy = configGoogle; // Redirect to google config
    config = configGoogle;
  }

  MapsAPIServiceImpl.withConfig({
    required MapAPIConfig config,
    @Deprecated('Viettel runtime implementation has been removed; this value is ignored.')
    String? viettelKey,
    required String googleKey,
  }) : super(resolveMapProvider(config.provider)) {
    String effectiveProvider = resolveMapProvider(config.provider);
    if (effectiveProvider == MapProviderConst.GOOGLE) {
      configGoogle = config;
      configLegacy = config;
      config.key = googleKey;
    }
    this.config = config;
  }

  // Use in the init method or when need to change provider
  void useProvider(String provider) {
    String effectiveProvider = resolveMapProvider(provider);
    if (effectiveProvider == MapProviderConst.GOOGLE) {
      setConfig(configGoogle);
    }
  }

  MapsAPIServiceImpl setConfig(MapAPIConfig config) {
    final currentKey = this.config.key;
    if (config.key == null && currentKey != null) {
      config.key = currentKey;
    }
    this.config = config;
    return this;
  }

  static MapsAPIServiceImpl get getInstance {
    final instance = _instance;
    if (instance != null) {
      return instance;
    } else {
      return MapsAPIServiceImpl(provider: MapProviderConst.GOOGLE);
    }
  }

  factory MapsAPIServiceImpl({
    @Deprecated('Viettel runtime implementation has been removed; this value is ignored.')
    String? viettelKey, 
    String? googleKey, 
    required String provider
  }) {
    String effectiveProvider = resolveMapProvider(provider);
    if (_instance == null) {
      _instance = MapsAPIServiceImpl._();
    }

    if (googleKey != null) {
      _instance?.configGoogle.key = googleKey;
    }
    
    _instance?.useProvider(effectiveProvider);

    return _instance as MapsAPIServiceImpl;
  }

  @override
  Future<List<GeocodingPlace>> geocode({
    double? lat,
    double? lng,
    String? placeId,
    String? address,
    String? bounds,
    Map<String, String>? paramsKeyMapper,
    CustomCancelToken? cancelToken,
  }) async {
    final keyLatLng = paramsKeyMapper.valueOrKey(MapsAPIConst.kLatLng);
    final keyPlaceId = paramsKeyMapper.valueOrKey(MapsAPIConst.kPlaceId);
    final keyAddress = paramsKeyMapper.valueOrKey(MapsAPIConst.kAddress);
    final keyBounds = paramsKeyMapper.valueOrKey(MapsAPIConst.kBounds);
    final params = {
      keyLatLng: '$lat,$lng',
      keyPlaceId: placeId,
      keyAddress: address,
      keyBounds: bounds,
    };
    params.removeWhere((key, value) => value == null);
    final response = await get<PlaceListingResponse>(
      config.geocodePath,
      params: params,
      cancelToken: cancelToken,
    );
    if (response.list == null) {
      debugPrint('API Maps geocode response content is null');
      return [];
    }

    // Since we resolve to GOOGLE, we primarily use Google parser.
    return GeocodingPlaceGoogle.parseListGeocoding(
      response.list as List<Map<String, dynamic>>,
    );
  }

  @override
  Future<DetailPlace> placeDetail({
    String? placeId,
    List<String>? fields,
    Map<String, String>? paramsKeyMapper,
    CustomCancelToken? cancelToken,
  }) async {
    final keyPlaceId = paramsKeyMapper.valueOrKey(MapsAPIConst.kPlaceId);
    final keyFields = paramsKeyMapper.valueOrKey(MapsAPIConst.kFields);
    final params = {
      keyPlaceId: placeId,
      keyFields: fields,
    };
    
    // Always treat as Google
    params[keyFields] = fields?.join(',') ?? '*';
    
    params.removeWhere((key, value) => value == null);
    final response = await get<PlaceResponse>(
      config.placeDetailPath,
      params: params,
      cancelToken: cancelToken,
      pathResource: placeId,
    );

    return DetailPlaceGoogle.fromJson(
      response.content as Map<String, dynamic>,
    );
  }

  @override
  Future<PlaceList<AutocompletePlace>> autocomplete({
    String? input,
    String? origin,
    String? location,
    String? radius,
    Map<String, String>? paramsKeyMapper,
    CustomCancelToken? cancelToken,
  }) async {
    final keyInput = paramsKeyMapper.valueOrKey(MapsAPIConst.kInput);
    final keyOrigin = paramsKeyMapper.valueOrKey(MapsAPIConst.kOrigin);
    final keyLocation = paramsKeyMapper.valueOrKey(MapsAPIConst.kLocation);
    final keyRadius = paramsKeyMapper.valueOrKey(MapsAPIConst.kRadius);
    final params = {
      keyInput: input,
      keyOrigin: origin,
      keyLocation: location,
      keyRadius: radius,
    };
    params.removeWhere((key, value) => value == null);

    final response = await post<PlaceListingResponse>(
      config.autocompleteSearchPath,
      params: AutocompletePlaceGoogle.googleAutocompleteParamsMapper(params),
      cancelToken: cancelToken,
    );
    return PlaceList.fromResponse(
        response, (json) => AutocompletePlaceGoogle.fromJson(json));
  }

  @override
  Future<PlaceList<NearbyPlace>> nearbySearch({
    String? keyword,
    double? lat,
    double? lng,
    int? radius,
    String? rankBy,
    String? nextPageToken,
    Map<String, String>? paramsKeyMapper,
    CustomCancelToken? cancelToken,
  }) async {
    // Nearby search keyword mapping for Google
    final keyKeyword = paramsKeyMapper.valueOrKey(MapsAPIConst.kType);
    final keyLocation = paramsKeyMapper.valueOrKey(MapsAPIConst.kLocation);
    final keyRadius = paramsKeyMapper.valueOrKey(MapsAPIConst.kRadius);
    final keyRankBy = paramsKeyMapper.valueOrKey(MapsAPIConst.kRankBy);
    final keyNextPageToken =
        paramsKeyMapper.valueOrKey(MapsAPIConst.kNextPageToken);
    final params = {
      keyKeyword: keyword,
      keyLocation: '$lat,$lng',
      keyRadius: radius,
      keyRankBy: rankBy,
      keyNextPageToken: nextPageToken,
    };
    params.removeWhere((key, value) => value == null);
    final response = await get<PlaceListingResponse>(
      config.nearbySearchPath,
      params: params,
      cancelToken: cancelToken,
    );
    final result = PlaceList.fromResponse(
      response,
      (json) => NearbyPlace.fromJson(json),
    );
    return result;
  }

  //[routePointsSkipStep]: skip every [routePointsSkipStep] route points if routes contains many points.
  @override
  Future<Directions> direction({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    bool alternatives = false,
    String? mode,
    Map<String, String>? paramsKeyMapper,
    int? routePointsSkipStep,
    List<LatLng>? waypoints,
    CustomCancelToken? cancelToken,
    Function(Map<String, dynamic> json)? onReceiveJson
  }) async {
    final keyOrigin = paramsKeyMapper.valueOrKey(MapsAPIConst.kOrigin);
    final keyDestination =
        paramsKeyMapper.valueOrKey(MapsAPIConst.kDestination);
    final keyAlternatives =
        paramsKeyMapper.valueOrKey(MapsAPIConst.kAlternatives);
    final keyMode = paramsKeyMapper.valueOrKey(MapsAPIConst.kMode);
    final keyWaypoints = paramsKeyMapper.valueOrKey(MapsAPIConst.kWayPoints);
    
    final params = {
      keyOrigin: '$originLat,$originLng',
      keyDestination: '$destLat,$destLng',
      keyAlternatives: alternatives,
      keyMode: mode,
      if (waypoints != null) 
        keyWaypoints: waypoints.map((e) => "${e.latitude},${e.longitude}").join("|"), 
    };
    final response = await get<PlaceResponse>(
      config.directionPath,
      params: params,
      cancelToken: cancelToken,
    );
    if (response.content is Map<String, dynamic>) {
      onReceiveJson?.call(response.content as Map<String, dynamic>);
      
      // Always use Google parser
      return Directions.fromJsonGoogle(
        response.content as Map<String, dynamic>,
        routePointsSkipStep: routePointsSkipStep,
      );
    } else {
      throw ImplicitServerResponseError(
        rootCause: Exception('API Maps directions response content is null'),
      );
    }
  }

  @override
  Future<DistanceMatrix> getDistanceMatrix({
    RouteTravelMode? travelMode = RouteTravelMode.bycycling,
    required List<LatLng> origins,
    required List<LatLng> destinations,
    Map<String, String>? paramsKeyMapper,
    CustomCancelToken? cancelToken,
    String? id,
    Function(Map<String, dynamic> json)? onReceiveJson,
  }) async {
    final keyOrigins = paramsKeyMapper.valueOrKey(MapsAPIConst.kOrigins);
    final keyDestinations =
    paramsKeyMapper.valueOrKey(MapsAPIConst.kDestinations);
    final keyMode = paramsKeyMapper.valueOrKey(MapsAPIConst.kMode);
    
    // Always use Google separator "|"
    final params = {
      keyOrigins: origins.map((e) => "${e.latitude},${e.longitude}").join("|"),
      keyDestinations:  destinations.map((e) => "${e.latitude},${e.longitude}").join("|"),
      keyMode: travelMode == RouteTravelMode.bycycling? "cycling": travelMode?.name,
    };

    params.removeWhere((key, value) => value == null);

    final response = await get<PlaceResponse>(
      config.distanceMatrixPath,
      params: params,
      cancelToken: cancelToken,
    );
    if (response.content is Map<String, dynamic>) {
      onReceiveJson?.call(response.content as Map<String, dynamic>);
      final result = DistanceMatrix.fromJson(
        response.content as Map<String, dynamic>,
      );
      result.id = id;
      return result;
    } else {
      throw ImplicitServerResponseError(
        rootCause: Exception('API Maps directions response content is null'),
      );
    }
  }
}
