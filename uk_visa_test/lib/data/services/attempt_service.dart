import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/api_response.dart';

final attemptServiceProvider = Provider<AttemptService>((ref) {
  final dio = ref.watch(dioProvider);
  return AttemptService(dio);
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

  /// Get attempt history
  Future<ApiResponse<Map<String, dynamic>>> getAttemptHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.attemptsHistory,
        queryParameters: {
          'page': page,
          'limit': limit,
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

  /// Get specific attempt details
  Future<ApiResponse<Map<String, dynamic>>> getAttemptDetail(int attemptId) async {
    try {
      final response = await _dio.get('${ApiConstants.attemptDetail}/$attemptId');
      return ApiResponse.fromJson(
        response.data,
            (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
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

  /// Get leaderboard
  Future<ApiResponse<List<dynamic>>> getLeaderboard() async {
    try {
      final response = await _dio.get('/attempts/leaderboard');
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
