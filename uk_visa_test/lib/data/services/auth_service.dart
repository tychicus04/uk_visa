// lib/data/services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/api_response.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthService(dio);
});

class AuthService {

  AuthService(this._dio);
  final Dio _dio;

  Future<ApiResponse<Map<String, dynamic>>> register({
    required String username,
    String languageCode = 'en',
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.authRegister,
        data: {
          'username': username,
          'language_code': languageCode,
        },
      );

      return ApiResponse.fromJson(
        response.data,
            (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String username,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.authLogin,
        data: {
          'username': username,
        },
      );

      return ApiResponse.fromJson(
        response.data,
            (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getProfile({required String userId}) async {
    try {
      final response = await _dio.get(
        ApiConstants.authProfile,
        data: {'user_id': userId},
      );

      return ApiResponse.fromJson(
        response.data,
            (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    required String userId,
    String? languageCode,
  }) async {
    try {
      final data = <String, dynamic>{'user_id': userId};
      if (languageCode != null) data['language_code'] = languageCode;

      final response = await _dio.put(
        ApiConstants.authProfile,
        data: data,
      );

      return ApiResponse.fromJson(
        response.data,
            (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateLanguagePreference({
    required String userId,
    required String languageCode,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.authLanguage,
        data: {
          'user_id': userId,
          'language_code': languageCode,
        },
      );

      return ApiResponse.fromJson(
        response.data,
            (json) => json! as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 🆕 NEW: Get translation statistics
  Future<ApiResponse<Map<String, dynamic>>> getTranslationStats() async {
    try {
      final response = await _dio.get('/stats/translations');

      return ApiResponse.fromJson(
        response.data,
            (json) => json! as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.authLogout);
    } on DioException catch (e) {
      // Ignore logout errors
      print('Logout error: ${e.message}');
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        return data['message'] ?? 'An error occurred';
      }
      return 'Server error: ${error.response!.statusCode}';
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Request timeout. Please try again.';
    } else {
      return 'Network error. Please check your connection.';
    }
  }
}
