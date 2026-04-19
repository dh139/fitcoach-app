import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/app_constants.dart';
import 'dio_interceptor.dart';

class ApiClient {
  ApiClient._();

  static final Dio _dio = _createDio();

  static Dio get dio => _dio;

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl:        AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept':       'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(),
      PrettyDioLogger(
        requestHeader:  false,
        requestBody:    true,
        responseBody:   true,
        responseHeader: false,
        compact:        true,
      ),
    ]);

    return dio;
  }

  // Helpers
  static Future<Response> get(String path, {Map<String, dynamic>? params}) =>
      _dio.get(path, queryParameters: params);

  static Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  static Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  static Future<Response> delete(String path) =>
      _dio.delete(path);

  // SSE streaming (for AI coach)
  static Future<Response> getStream(String path, {dynamic data}) =>
      _dio.post(path, data: data,
        options: Options(responseType: ResponseType.stream));
}