import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/api_response.dart';

final questionServiceProvider = Provider<QuestionService>((ref) {
  final dio = ref.watch(dioProvider);
  return QuestionService(dio);
});

class QuestionService {

  QuestionService(this._dio);

  final Dio _dio;

  Future<ApiResponse<Map<String, dynamic>>> getQuestion(int questionId, {
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
