import 'package:dio/dio.dart';

import 'api_endpoints.dart';
import 'auth_interceptor.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;

  late final Dio mlDio = Dio(BaseOptions(
    baseUrl: ApiEndpoints.mlBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Accept': 'application/json',
    },
  ))..interceptors.add(MlSecretInterceptor());

  late final Dio backendDio = Dio(BaseOptions(
    baseUrl: ApiEndpoints.backendBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ))..interceptors.add(BackendAuthInterceptor());

  Future<Response<T>> mlPost<T>(String path, {dynamic data}) {
    return mlDio.post<T>(path, data: data);
  }

  Future<Response<T>> mlGet<T>(String path, {Map<String, dynamic>? queryParameters}) {
    return mlDio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> mlUpload<T>(
    String path, {
    required FormData formData,
  }) {
    return mlDio.post<T>(path, data: formData);
  }

  Future<Response<T>> backendGet<T>(String path, {Map<String, dynamic>? queryParameters}) {
    return backendDio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> backendPost<T>(String path, {dynamic data}) {
    return backendDio.post<T>(path, data: data);
  }

  Future<Response<T>> backendPatch<T>(String path, {dynamic data}) {
    return backendDio.patch<T>(path, data: data);
  }
}
