import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

abstract class ApiChinalco {
  ApiChinalco();

  static Dio dio = Dio();

  @protected
  Dio get client => Dio(options);

  @protected
  Logger get logger => Logger('$runtimeType');

  static set user(String? user) =>
      dio.options.headers['Authorization'] = 'Basic $user';

  static String? get user =>
      (dio.options.headers['Authorization'] as String?)?.split(' ').last;

  static Dio createDio({
    required String baseUrl,
    required String apiKey,
    String? user,
  }) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'Authorization': 'Basic $user',
          'API_KEY': apiKey,
          Headers.acceptHeader: Headers.jsonContentType,
          Headers.contentTypeHeader: Headers.jsonContentType,
        },
        followRedirects: false,
      ),
    );
  }

  @protected
  @mustBeOverridden
  String get endpoint;

  @protected
  BaseOptions get options => dio.options.copyWith(
        baseUrl: '${dio.options.baseUrl}/$endpoint',
      );

  // Future<T> get<T>({
  //   required String path,
  //   Map<String, dynamic>? queryParameters,
  // }) async {
  //   final response = await dio.get<T>(
  //     path,
  //   );
  //
  //   return response.data!;
  // }
  //
  // Future<T> post<T>({
  //   required String path,
  //   required dynamic data,
  // }) async {
  //   final response = await dio.post<T>(
  //     path,
  //     data: data,
  //   );
  //
  //   return response.data!;
  // }
  //
  // Future<T> put<T>({
  //   required String path,
  //   required dynamic data,
  // }) async {
  //   final response = await dio.put<T>(
  //     path,
  //     data: data,
  //   );
  //
  //   return response.data!;
  // }
  //
  // Future<T> delete<T>({
  //   required String path,
  //   Map<String, dynamic>? queryParameters,
  // }) async {
  //   final response = await dio.delete<T>(
  //     path,
  //     queryParameters: queryParameters,
  //   );
  //
  //   return response.data!;
  // }
}
