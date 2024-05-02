import 'dart:io';

import 'package:dio/io.dart';
import 'package:dio/dio.dart';

import '../models/network/custom_cancel_token.dart';
import '../models/network/json_response.dart';
import 'api_service.dart';
import 'cache/cache.dart';
part 'dio_interceptors.dart';

const int sendTimeout = 60000;
const int receiveTimeout = 60000;
const int connectTimeout = 60000;

Future<V> get<V extends JsonResponse>(String host, String path,
    {Map<String, String>? headers,
    CustomCancelToken? cancelToken,
    Map<String, dynamic>? params,
    InterceptorsWrapper? customInterceptors,
    int sendTimeout = sendTimeout,
    int receiveTimeout = receiveTimeout,
    int connectTimeout = connectTimeout,
    required Function(Response res) parser}) async {
  final dio = prepareDio(interceptors: customInterceptors ?? interceptors);
  dio.options.sendTimeout = Duration(milliseconds: sendTimeout);
  dio.options.receiveTimeout = Duration(milliseconds: receiveTimeout);
  dio.options.connectTimeout = Duration(milliseconds: connectTimeout);
  final response = await dio.get(
    '$host/$path',
    queryParameters: params,
    cancelToken: cancelToken,
    options: Options(headers: headers),
  );
  return parser(response);
}

Future<V> post<V extends JsonResponse>(
  String host,
  String path,
  dynamic body, {
  Map<String, String>? headers,
  CustomCancelToken? cancelToken,
  InterceptorsWrapper? customInterceptors,
  int sendTimeout = sendTimeout,
  int receiveTimeout = receiveTimeout,
  int connectTimeout = connectTimeout,
  required Function(Response res) parser,
}) async {
  final dio = prepareDio(interceptors: customInterceptors ?? interceptors);
  dio.options.sendTimeout = Duration(milliseconds: sendTimeout);
  dio.options.receiveTimeout = Duration(milliseconds: receiveTimeout);
  dio.options.connectTimeout = Duration(milliseconds: connectTimeout);
  final response = await dio.post(
    '$host/$path',
    data: body,
    cancelToken: cancelToken,
    options: Options(headers: headers),
  );
  return parser(response);
}

Future<File> download(
  String url,
  String savePath, {
  CustomCancelToken? cancelToken,
  ProgressCallback? onReceiveProgress,
  InterceptorsWrapper? customInterceptors,
}) async {
  final dio = prepareDio(interceptors: customInterceptors ?? interceptors);
  await dio.download(
    url,
    savePath,
    cancelToken: cancelToken,
    onReceiveProgress: onReceiveProgress,
  );
  File file = File(savePath);
  return file;
}

Dio prepareDio({required InterceptorsWrapper interceptors}) {
  final dio = Dio()..interceptors.add(interceptors);
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final HttpClient client = HttpClient(context: SecurityContext(withTrustedRoots: false));
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return client;
  };
  return dio;
}
