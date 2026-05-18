import 'package:flutter/material.dart';
import 'package:maps_core/maps/constants.dart';
import 'package:maps_core/maps/extensions/utils.dart';

import '../models/models.dart';
import '../models/network/custom_cancel_token.dart';
import 'maps_api_config.dart';
import 'maps_api_service.dart';

class MapsAPIServiceImpl extends MapsAPIService {
  static MapsAPIServiceImpl? _instance;

  @override
  late MapAPIConfig configViettel;

  @override
  late MapAPIConfig configGoogle;

  @protected
  @override
  MapsAPIResponseParser jsonParser = MapsAPIResponseParser.link([
    MapsAPIGeocodingParser(),
    MapsAPIAutocompleteSearchParser(),
    MapsAPIPlaceDetailParser(),
    MapsAPIDirectionsParser(),
  ]);

  // Private constructor
  MapsAPIServiceImpl._() : super(MapProviderConst.VIETTEL) {
    configViettel = MapAPIConfig.getConfig(MapProviderConst.VIETTEL);
    configGoogle = MapAPIConfig.getConfig(MapProviderConst.GOOGLE);
    config = configViettel; // Set default config to Viettel
  }

  MapsAPIServiceImpl.withConfig({
    required MapAPIConfig config,
    required String viettelKey,
    required String googleKey,
  }) : super(config.provider) {
    config.provider == MapProviderConst.VIETTEL ? configViettel = config : configGoogle = config;
    config.key = config.provider == MapProviderConst.VIETTEL ? viettelKey : googleKey;
  }

  // Use in the init method or when need to change provider
  void useProvider(String provider) {
   provider == MapProviderConst.GOOGLE ? setConfig(configGoogle) : setConfig(configViettel);
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
      return MapsAPIServiceImpl(provider: MapProviderConst.VIETTEL);
    }
  }

  String get provider => config.provider;

  factory MapsAPIServiceImpl({String? viettelKey, String? googleKey, String? id, String? fingerprint, required String provider}) {
    if (_instance == null) {
      _instance = MapsAPIServiceImpl._();
      _instance?.config = MapAPIConfig.getConfig(provider);
    }
    if (viettelKey != null) {
      _instance?.configViettel.key = viettelKey;
    }
    if (googleKey != null) {
      _instance?.configGoogle.key = googleKey;
    }
    if (id != null) {
      _instance?.configGoogle.id = id;
      _instance?.configViettel.id = id;
      _instance?.config.id = id;
    }
    if (fingerprint != null) {
      _instance?.configGoogle.fingerprint = fingerprint;
      _instance?.configViettel.fingerprint = fingerprint;
      _instance?.config.fingerprint = fingerprint;
    }
    _instance?.useProvider(provider);

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

    if (config.provider == MapProviderConst.GOOGLE) {
      return GeocodingPlaceGoogle.parseListGeocoding(
        response.list as List<Map<String, dynamic>>,
      );
    }
    else if (config.provider == MapProviderConst.VIETTEL) {
      return GeocodingPlace.parseListGeocoding(
        response.list as List<Map<String, dynamic>>,
      );
    }
    else {
      throw ImplicitServerResponseError(
        rootCause: Exception('Provider not supported'),
      );
    }
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
    if (config.provider == MapProviderConst.GOOGLE) {
      params[keyFields] = fields?.join(',') ?? '*';
    }
    params.removeWhere((key, value) => value == null);
    final response = await get<PlaceResponse>(
      config.placeDetailPath,
      params: params,
      cancelToken: cancelToken,
      pathResource: config.provider == MapProviderConst.GOOGLE ? placeId : null,
    );

    if (config.provider == MapProviderConst.GOOGLE) {
      return DetailPlaceGoogle.fromJson(
        response.content as Map<String, dynamic>,
      );
    }
    else if (config.provider == MapProviderConst.VIETTEL) {
      return DetailPlace.fromJson(
        response.content as Map<String, dynamic>,
      );
    }
    else {
      throw ImplicitServerResponseError(
        rootCause: Exception('Provider not supported'),
      );
    }
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

    PlaceList<AutocompletePlace> result;
    if (config.provider == MapProviderConst.GOOGLE) {
      final response = await post<PlaceListingResponse>(
        config.autocompleteSearchPath,
        params: AutocompletePlaceGoogle.googleAutocompleteParamsMapper(params),
        cancelToken: cancelToken,
      );
      result = PlaceList.fromResponse(
          response, (json) => AutocompletePlaceGoogle.fromJson(json));
    }
    else if (config.provider == MapProviderConst.VIETTEL) {
      final response = await get<PlaceListingResponse>(
        config.autocompleteSearchPath,
        params: params,
        cancelToken: cancelToken,
      );
      result = PlaceList.fromResponse(
          response, (json) => AutocompletePlace.fromJson(json));
    } else {
      throw ImplicitServerResponseError(
        rootCause: Exception('Provider not supported'),
      );
    }
    return result;
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
    final keyKeyword = paramsKeyMapper.valueOrKey(config.provider == MapProviderConst.GOOGLE ? MapsAPIConst.kType : MapsAPIConst.kKeyword);
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
      if (waypoints != null) keyWaypoints: config.provider == MapProviderConst.GOOGLE
          ? waypoints.map((e) => "${e.latitude},${e.longitude}").join("|")
          : waypoints.map((e) => "${e.latitude},${e.longitude}").join(";"),
    };
    final response = await get<PlaceResponse>(
      config.directionPath,
      params: params,
      cancelToken: cancelToken,
    );
    if (response.content is Map<String, dynamic>) {
      onReceiveJson?.call(response.content as Map<String, dynamic>);
      if (config.provider == MapProviderConst.GOOGLE) {
        return Directions.fromJsonGoogle(
          response.content as Map<String, dynamic>,
          routePointsSkipStep: routePointsSkipStep,
        );
      }
      else if (config.provider == MapProviderConst.VIETTEL) {
        return Directions.fromJson(
          response.content as Map<String, dynamic>,
          routePointsSkipStep: routePointsSkipStep,
        );
      }
      else {
        throw ImplicitServerResponseError(
          rootCause: Exception('Provider not supported'),
        );
      }
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
    final params = {
      keyOrigins: origins.map((e) => "${e.latitude},${e.longitude}").join(config.provider == MapProviderConst.GOOGLE ? "|" : ";"),
      keyDestinations:  destinations.map((e) => "${e.latitude},${e.longitude}").join(config.provider == MapProviderConst.GOOGLE ? "|" : ";"),
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
