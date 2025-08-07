import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/api_response.dart';

final chapterServiceProvider = Provider<ChapterService>((ref) {
  final dio = ref.watch(dioProvider);
  return ChapterService(dio);
});

class ChapterService {
  final Dio _dio;

  ChapterService(this._dio);

  /// Get all chapters
  Future<ApiResponse<List<dynamic>>> getAllChapters() async {
    try {
      final response = await _dio.get(ApiConstants.chapters);
      return ApiResponse.fromJson(
        response.data,
            (json) => json as List<dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get specific chapter with tests
  Future<ApiResponse<Map<String, dynamic>>> getChapter(int chapterId) async {
    try {
      final response = await _dio.get('${ApiConstants.chapterDetail}/$chapterId');
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