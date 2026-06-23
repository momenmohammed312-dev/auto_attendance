import 'package:dio/dio.dart';

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
