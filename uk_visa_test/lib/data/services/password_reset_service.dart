// lib/data/services/password_reset_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/api_response.dart';

final passwordResetServiceProvider = Provider<PasswordResetService>((ref) {
  final dio = ref.watch(dioProvider);
  return PasswordResetService(dio);
});

class PasswordResetService {
  final Dio _dio;

  PasswordResetService(this._dio);

  /// Send forgot password email
  Future<ApiResponse<Map<String, dynamic>>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.authForgotPassword,
        data: {
          'email': email,
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

  /// Verify reset token validity
  Future<ApiResponse<Map<String, dynamic>>> verifyResetToken({
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.authVerifyResetToken,
        data: {
          'token': token,
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

  /// Reset password with token
  Future<ApiResponse<Map<String, dynamic>>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.authResetPassword,
        data: {
          'token': token,
          'new_password': newPassword,
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