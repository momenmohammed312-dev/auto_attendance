import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';
import 'api_endpoints.dart';

/// Interceptor that adds the ML API secret key to requests.
class MlSecretInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.baseUrl == ApiEndpoints.mlBaseUrl) {
      options.headers[ApiEndpoints.mlSecretHeader] = ApiEndpoints.mlSecretKey;
    }
    handler.next(options);
  }
}

/// Interceptor that adds JWT auth token from SecureStorage to backend API requests.
class BackendAuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await secureStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
