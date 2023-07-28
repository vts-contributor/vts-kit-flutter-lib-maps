import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:maps_core/maps/extensions/utils.dart';
import 'package:maps_core/maps/services/maps_api_interceptor.dart';

import '../../log/log.dart';
import '../models/network/custom_cancel_token.dart';
import '../models/network/maps_api_response.dart';
import '../models/network/maps_api_response_parser.dart';
import 'maps_api_config.dart';

import 'dio_network.dart' as dio_network;

abstract class MapsAPIAbstractService {
  @protected
  abstract MapAPIConfig config;
  @protected
  abstract MapsAPIResponseParser jsonParser;

  MapsAPIResponse _parseJsonFun(Response response) =>
      jsonParser.parse(response);

  @protected
  Future<V> get<V extends MapsAPIResponse>(String path,
      {Map<String, String>? headers,
      CustomCancelToken? cancelToken,
      Map<String, dynamic>? params,
      InterceptorsWrapper? customInterceptors,
      int sendTimeout = dio_network.sendTimeout,
      int receiveTimeout = dio_network.receiveTimeout,
      int connectTimeout = dio_network.connectTimeout,
      Function(Response res)? parser}) async {
    try {
      if (config.key.isNullOrEmpty) {
        throw Exception('Not found Maps key');
      }
      final InterceptorsWrapper interceptors;
      if (customInterceptors == null) {
        interceptors = MapsAPIInterceptorsWrapper()..config = config;
      } else {
        interceptors = customInterceptors;
      }
      final result = await dio_network.get<V>(
        config.hostOf(path),
        path,
        parser: parser ?? _parseJsonFun,
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
}
