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
  final Dio _dio;

  TestService(this._dio);

  /// Get available tests for user
  Future<ApiResponse<Map<String, dynamic>>> getAvailableTests() async {
    try {
      final response = await _dio.get(ApiConstants.testsAvailable);
      return ApiResponse.fromJson(
        response.data,
            (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get free tests (no auth required)
  Future<ApiResponse<List<dynamic>>> getFreeTests() async {
    try {
      final response = await _dio.get(ApiConstants.testsFree);
      return ApiResponse.fromJson(
        response.data,
            (json) => json as List<dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get specific test with questions
  Future<ApiResponse<Map<String, dynamic>>> getTest(int testId) async {
    try {
      final response = await _dio.get('${ApiConstants.testDetail}/$testId');
      return ApiResponse.fromJson(
        response.data,
            (json) => json as Map<String, dynamic>,
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
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (query != null) queryParams['q'] = query;
      if (type != null) queryParams['type'] = type;
      if (chapterId != null) queryParams['chapter_id'] = chapterId;

      final response = await _dio.get(
        ApiConstants.testsSearch,
        queryParameters: queryParams,
      );

      return ApiResponse.fromJson(
        response.data,
            (json) => json as List<dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get tests by type
  Future<ApiResponse<List<dynamic>>> getTestsByType(String type) async {
    try {
      final response = await _dio.get('/tests/type/$type');
      return ApiResponse.fromJson(
        response.data,
            (json) => json as List<dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get tests by chapter
  Future<ApiResponse<List<dynamic>>> getTestsByChapter(int chapterId) async {
    try {
      final response = await _dio.get('/tests/chapter/$chapterId');
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