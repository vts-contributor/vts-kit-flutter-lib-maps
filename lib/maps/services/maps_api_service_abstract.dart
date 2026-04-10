import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:maps_core/maps/extensions/utils.dart';
import 'package:maps_core/maps/services/maps_api_interceptor.dart';
import 'package:maps_core/maps/constants.dart';

import '../../log/log.dart';
import '../models/network/custom_cancel_token.dart';
import '../models/network/maps_api_response.dart';
import '../models/network/maps_api_response_parser.dart';
import 'maps_api_config.dart';

import 'dio_network.dart' as dio_network;

abstract class MapsAPIAbstractService {
  @protected
  late MapAPIConfig config;
  @protected
  abstract MapsAPIResponseParser jsonParser;

  MapsAPIAbstractService(String provider) {
    config = MapAPIConfig.getConfig(provider);
  }

  MapsAPIResponse _parseJsonFun(Response response) =>
      jsonParser.parse(response);

  MapsAPIResponse _parseJsonFunPlaceAPINew(Response response) {
    if (response.data.containsKey('result')) {
      return jsonParser.parse(response);
    }
    response.data = {
      'result': response.data,
      'status': response.statusCode == 200 ? 'OK' : 'ZERO_RESULTS',
    };
    return jsonParser.parse(response);
  }

  MapsAPIResponse _parseJsonFunAutocompleteNew(Response response) {
    if (response.data.containsKey('result')) {
      return jsonParser.parse(response);
    }
    response.data = {
      'predictions': response.data['suggestions'],
      'status': response.statusCode == 200 ? 'OK' : 'ZERO_RESULTS',
    };
    return jsonParser.parse(response);
  }

  @protected
  Future<V> get<V extends MapsAPIResponse>(String path,
      {Map<String, String>? headers,
        CustomCancelToken? cancelToken,
        Map<String, dynamic>? params,
        InterceptorsWrapper? customInterceptors,
        int sendTimeout = dio_network.sendTimeout,
        int receiveTimeout = dio_network.receiveTimeout,
        int connectTimeout = dio_network.connectTimeout,
        String? pathResource, // Use where the resource is in the path, not in query
        Function(Response res)? parser}) async {
    try {
      if (config.key.isNullOrEmpty) {
        throw Exception('Not found Maps key');
      }
      InterceptorsWrapper? interceptors;
      if (customInterceptors == null) {
        interceptors = MapsAPIInterceptorsWrapper()..config = config;
      } else {
        interceptors = customInterceptors;
      }
      String hostPath = config.hostOf(path);

      // Viettel Maps use /places?place_id=...
      // Google Maps use /{place_id}?
      if (pathResource != null) {
        path = "$path/$pathResource";
        params?.removeWhere((key, value) => value == pathResource);
      }
      parser ??= (config.provider == MapProviderConst.GOOGLE && hostPath == config.placeHost)
          ? _parseJsonFunPlaceAPINew
          : _parseJsonFun;

      final result = await dio_network.get<V>(
        hostPath,
        path,
        parser: parser,
        cancelToken: cancelToken,
        params: params,
        customInterceptors: interceptors,
        sendTimeout: sendTimeout,
        receiveTimeout: receiveTimeout,
        connectTimeout: connectTimeout,
      );
      return result;
    } on Exception catch (e) {
      Log.e('MapsAPIAbstractService get', '', throwable: e);
      rethrow;
    }
  }

  @protected
  Future<V> post<V extends MapsAPIResponse>(String path,
      {Map<String, String>? headers,
        CustomCancelToken? cancelToken,
        Map<String, dynamic>? params,
        InterceptorsWrapper? customInterceptors,
        int sendTimeout = dio_network.sendTimeout,
        int receiveTimeout = dio_network.receiveTimeout,
        int connectTimeout = dio_network.connectTimeout}) async {
    try {
      if (config.key.isNullOrEmpty) {
        throw Exception('Not found Maps key');
      }
      InterceptorsWrapper? interceptors;
      if (customInterceptors == null) {
        interceptors = MapsAPIInterceptorsWrapper()..config = config;
      } else {
        interceptors = customInterceptors;
      }
      String hostPath = config.hostOf(path);

      final result = await dio_network.post<V>(
        hostPath,
        path,
        params,
        cancelToken: cancelToken,
        customInterceptors: interceptors,
        sendTimeout: sendTimeout,
        receiveTimeout: receiveTimeout,
        connectTimeout: connectTimeout,
        parser: _parseJsonFunAutocompleteNew,
      );
      return result;
    } on Exception catch (e) {
      Log.e('MapsAPIAbstractService post', '', throwable: e);
      rethrow;
    }
  }
}
