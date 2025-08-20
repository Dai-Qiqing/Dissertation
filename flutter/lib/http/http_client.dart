import 'package:dio/dio.dart';
import 'package:flutter_outfit/index.dart';

class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  final Dio dio = Dio();

  factory HttpClient() {
    return _instance;
  }

  HttpClient._internal() {
    var options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: {
        'Content-Type': 'application/json',
      },
      validateStatus: (status) {
        // 允许所有状态码返回，交给你自己处理
        return true;
      },
      connectTimeout: Duration(seconds: ApiConfig.connectTimeout),
      receiveTimeout: Duration(seconds: ApiConfig.receiveTimeout),
    );
    dio.options = options;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          // 如果你想完成请求并返回一些自定义数据，你可以使用 `handler.resolve(response)`。
          // 如果你想终止请求并触发一个错误，你可以使用 `handler.reject(error)`。
          print('Request url: ${options.uri}');
          print('Request data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (Response response, ResponseInterceptorHandler handler) {
          // 如果你想终止请求并触发一个错误，你可以使用 `handler.reject(error)`。
          print('Response: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) {
          // 如果你想完成请求并返回一些自定义数据，你可以使用 `handler.resolve(response)`。
          print('Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }
}
