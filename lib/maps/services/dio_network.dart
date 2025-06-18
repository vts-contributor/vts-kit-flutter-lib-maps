import 'dart:convert';
import 'dart:developer';
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
const int connectTimeout = 10000;

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
  //
  // // Add logging interceptor
  // dio.interceptors.add(InterceptorsWrapper(
  //   onRequest: (options, handler) {
  //     final queryString = options.queryParameters.entries
  //         .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
  //         .join('&');
  //     final curl = StringBuffer('curl -X ${options.method} "${options.baseUrl}${options.path}?$queryString"');
  //     if (options.headers.isNotEmpty) {
  //       options.headers.forEach((key, value) {
  //         curl.write(' -H "${key}: ${value}"');
  //       });
  //     }
  //     if (options.data != null) {
  //       curl.write(' --data \'${options.data}\'');
  //     }
  //     print('CURL: $curl');
  //     log('CURL: $curl');
  //     return handler.next(options); // Continue with the request
  //   },
  //   onResponse: (response, handler) {
  //     print('Response: ${response.requestOptions.method} ${response.requestOptions.uri} ${response.statusCode} ${response.statusMessage} ${response.data}');
  //     print('Status Code: ${response.statusCode}');
  //     // response.statusCode = 500;
  //     // response.data = {
  //     //   'status': 500,
  //     //   'message': "Forwarding error"
  //     // };
  //     // print('Data: ${jsonEncode(response.data)}');
  //     // Future.delayed(
  //     //   const Duration(seconds: 30),
  //     //   () => print('Response: ${response.statusCode}'),
  //     // );
  //     return handler.next(response); // Continue with the response
  //   },
  //   onError: (DioError error, handler) {
  //     print('Error:');
  //     print('Message: ${error.message}');
  //     if (error.response != null) {
  //       print('Status Code: ${error.response?.statusCode}');
  //       print('Data: ${jsonEncode(error.response?.data)}');
  //     }
  //     return handler.next(error); // Continue with the error
  //   },
  // ));

  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final HttpClient client = HttpClient(context: SecurityContext(withTrustedRoots: false));
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return client;
  };
  return dio;
}
