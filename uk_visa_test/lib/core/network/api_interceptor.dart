// lib/core/network/api_interceptor.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';

class ApiInterceptor extends Interceptor {
  final Ref ref;

  ApiInterceptor(this.ref);

  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    // Add auth token if available
    final token = await SecureStorageService.instance.getAuthToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 errors (unauthorized)
    if (err.response?.statusCode == 401) {
      // Try to refresh token
      final refreshToken = await SecureStorageService.instance.getRefreshToken();
      if (refreshToken != null) {
        try {
          // TODO: Implement token refresh logic
          // For now, just clear tokens and force re-login
          await SecureStorageService.instance.clearAll();
        } catch (e) {
          // Refresh failed, clear tokens
          await SecureStorageService.instance.clearAll();
        }
      }
    }

    super.onError(err, handler);
  }
}
