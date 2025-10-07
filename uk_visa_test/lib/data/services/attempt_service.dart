import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../models/api_response.dart';
import 'offline_attempt_service.dart';

// Use offline attempt service for now
final attemptServiceProvider = Provider<OfflineAttemptService>((ref) {
  return ref.watch(offlineAttemptServiceProvider);
});

class AttemptService {

  AttemptService(this._dio);
  final Dio _dio;

  /// Start a new test attempt
  Future<ApiResponse<Map<String, dynamic>>> startAttempt(int testId) async {
    try {
      final response = await _dio.post(
        ApiConstants.attemptsStart,
        data: {'test_id': testId},
      );
      return ApiResponse.fromJson(
        response.data,
            (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Submit test attempt
  Future<ApiResponse<Map<String, dynamic>>> submitAttempt({
    required int attemptId,
    required List<Map<String, dynamic>> answers,
    int? timeTaken,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.attemptsSubmit,
        data: {
          'attempt_id': attemptId,
          'answers': answers,
          'time_taken': timeTaken,
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

  /// Get attempt history with language support
  Future<ApiResponse<Map<String, dynamic>>> getAttemptHistory({
    int page = 1,
    int limit = 20,
    String? secondaryLanguage,
    bool includeVietnamese = false, // Backward compatibility
  }) async {
    try {
      print('🔄 Service: Loading attempt history page $page, limit $limit (Language: ${secondaryLanguage ?? 'none'})');

      // Build query parameters with dynamic language support
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      // 🆕 NEW: Dynamic language support
      if (secondaryLanguage != null && ApiConstants.isSupportedLanguage(secondaryLanguage)) {
        queryParams[ApiConstants.paramIncludeLanguage] = secondaryLanguage;
      }
      // 🔄 DEPRECATED: Backward compatibility
      else if (includeVietnamese) {
        queryParams[ApiConstants.paramIncludeVietnamese] = 'true';
      }

      final response = await _dio.get(
        ApiConstants.attemptsHistory,
        queryParameters: queryParams,
      );

      print('✅ Service: Attempt history API response received with language support');

      return ApiResponse.fromJson(
        response.data,
            (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// ✅ ENHANCED: Get specific attempt details with dynamic multi-language support
  Future<ApiResponse<Map<String, dynamic>>> getAttemptDetail(
      int attemptId, {
        String? secondaryLanguage,
        bool includeVietnamese = false, // Backward compatibility
      }) async {
    try {
      print('🔄 Service: Loading attempt detail $attemptId (Language: ${secondaryLanguage ?? 'none'})');

      // 🆕 ENHANCED: Build query parameters with dynamic language support
      final queryParams = <String, dynamic>{};

      // Priority 1: New dynamic language parameter
      if (secondaryLanguage != null && ApiConstants.isSupportedLanguage(secondaryLanguage)) {
        queryParams[ApiConstants.paramIncludeLanguage] = secondaryLanguage;
        print('🌍 Service: Using dynamic language parameter: $secondaryLanguage');
      }
      // Priority 2: Backward compatibility with Vietnamese
      else if (includeVietnamese) {
        queryParams[ApiConstants.paramIncludeVietnamese] = 'true';
        print('🇻🇳 Service: Using legacy Vietnamese parameter for backward compatibility');
      }

      final response = await _dio.get(
        '${ApiConstants.attemptDetail}/$attemptId',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      print('✅ Service: Attempt detail API response received with language: ${secondaryLanguage ?? 'none'}');

      return ApiResponse.fromJson(
        response.data,
            (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      print('💥 Service: DioException in getAttemptDetail: ${e.message}');
      throw _handleError(e);
    }
  }

  /// Retake a test
  Future<ApiResponse<Map<String, dynamic>>> retakeTest(int testId) async {
    try {
      final response = await _dio.post(
        '/attempts/retake',
        data: {'test_id': testId},
      );
      return ApiResponse.fromJson(
        response.data,
            (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get leaderboard with language support
  Future<ApiResponse<List<dynamic>>> getLeaderboard({
    String? secondaryLanguage,
    bool includeVietnamese = false, // Backward compatibility
  }) async {
    try {
      print('🔄 Service: Loading leaderboard (Language: ${secondaryLanguage ?? 'none'})');

      // Build query parameters with dynamic language support
      final queryParams = <String, dynamic>{};

      if (secondaryLanguage != null && ApiConstants.isSupportedLanguage(secondaryLanguage)) {
        queryParams[ApiConstants.paramIncludeLanguage] = secondaryLanguage;
      } else if (includeVietnamese) {
        queryParams[ApiConstants.paramIncludeVietnamese] = 'true';
      }

      final response = await _dio.get(
        '/attempts/leaderboard',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      print('✅ Service: Leaderboard API response received with language support');

      return ApiResponse.fromJson(
        response.data,
            (json) => json as List<dynamic>,
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