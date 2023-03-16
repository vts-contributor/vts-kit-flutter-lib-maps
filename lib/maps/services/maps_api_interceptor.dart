import 'package:dio/dio.dart';

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
    handler.next(options);
  }
}
