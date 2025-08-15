import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/api_response.dart';

final testServiceProvider = Provider<TestService>((ref) {
  final dio = ref.watch(dioProvider);
  return TestService(dio);
});

class TestService {

  TestService(this._dio);
  final Dio _dio;

  /// Get available tests for user
  Future<ApiResponse<Map<String, dynamic>>> getAvailableTests({
    bool includeVietnamese = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (includeVietnamese) {
        queryParams['include_vietnamese'] = 'true';
      }

      final response = await _dio.get(
          ApiConstants.testsAvailable,
          queryParameters: queryParams.isNotEmpty ? queryParams : null);

      return ApiResponse.fromJson(
        response.data,
            (json) => json! as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<List<dynamic>>> getFreeTests({
    bool includeVietnamese = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (includeVietnamese) {
        queryParams['include_vietnamese'] = 'true';
      }
      final response = await _dio.get(
          ApiConstants.testsFree,
          queryParameters: queryParams.isNotEmpty ? queryParams : null);

      return ApiResponse.fromJson(
        response.data,
            (json) => json! as List<dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get specific test with questions
  Future<ApiResponse<Map<String, dynamic>>> getTest(
      int testId,
      { bool includeVietnamese = false,
        bool includeCorrectAnswers = false}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (includeVietnamese) {
        queryParams['include_vietnamese'] = 'true';
      }
      if (includeCorrectAnswers) {
        queryParams['include_answers'] = 'true';
      }
      final response = await _dio.get(
        '${ApiConstants.testDetail}/$testId',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return ApiResponse.fromJson(
        response.data,
            (json) => json! as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Search tests
  Future<ApiResponse<List<dynamic>>> searchTests({
    String? query,
    String? type,
    int? chapterId,
    bool includeVietnamese = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (query != null) {
        queryParams['q'] = query;
      }
      if (type != null) {
        queryParams['type'] = type;
      }
      if (chapterId != null) {
        queryParams['chapter_id'] = chapterId;
      }
      if (includeVietnamese) {
        queryParams['include_vietnamese'] = 'true';
      }

      final response = await _dio.get(
        ApiConstants.testsSearch,
        queryParameters: queryParams,
      );

      return ApiResponse.fromJson(
        response.data,
            (json) => json! as List<dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get tests by type
  Future<ApiResponse<List<dynamic>>> getTestsByType(
      String type,
      { bool includeVietnamese = false}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (includeVietnamese) {
        queryParams['include_vietnamese'] = 'true';
      }

      final response = await _dio.get(
          '${ApiConstants.testByType}/$type',
          queryParameters: queryParams.isNotEmpty ? queryParams : null);
      return ApiResponse.fromJson(
        response.data,
            (json) => json! as List<dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get tests by chapter
  Future<ApiResponse<List<dynamic>>> getTestsByChapter(
      int chapterId,
      {bool includeVietnamese = false}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (includeVietnamese) {
        queryParams['include_vietnamese'] = 'true';
      }
      final response = await _dio.get(
          '${ApiConstants.testByChapter}/$chapterId',
          queryParameters: queryParams.isNotEmpty ? queryParams : null);
      return ApiResponse.fromJson(
        response.data,
            (json) => json! as List<dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getQuestion(
      int questionId, {
        bool includeVietnamese = false,
        bool includeCorrectAnswers = false,
      }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (includeVietnamese) {
        queryParams['include_vietnamese'] = 'true';
      }
      if (includeCorrectAnswers) {
        queryParams['include_answers'] = 'true';
      }

      final response = await _dio.get(
        '${ApiConstants.questions}/$questionId',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return ApiResponse.fromJson(
        response.data,
            (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateLanguagePreference(
      String languageCode,
      ) async {
    try {
      final response = await _dio.post(
        ApiConstants.authLanguage,
        data: {
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