import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:maps_core/maps/constants.dart';

import 'maps_api_config.dart';

class MapsAPIInterceptorsWrapper extends InterceptorsWrapper {
  static MapsAPIInterceptorsWrapper? _instance;
  late MapAPIConfig config;

  MapsAPIInterceptorsWrapper._();

  factory MapsAPIInterceptorsWrapper() {
    _instance ??= MapsAPIInterceptorsWrapper._();
    return _instance as MapsAPIInterceptorsWrapper;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!options.queryParameters.containsKey('key')) {
      options.queryParameters['key'] = config.key;
    }
    if (config.provider == MapProviderConst.GOOGLE && config.id != null) {
      if (Platform.isAndroid) {
        options.headers['X-Android-Package'] = config.id;
      } else if (Platform.isIOS) {
        options.headers['X-Ios-Bundle-Identifier'] = config.id;
      }
    }
    if (config.provider == MapProviderConst.GOOGLE && config.fingerprint != null) {
      if (Platform.isAndroid) {
        options.headers['X-Android-Cert'] = config.fingerprint;
      }
    }
    debugPrint("MapsAPIInterceptorsWrapper onRequest ${options.path}");
    handler.next(options);
  }
}
