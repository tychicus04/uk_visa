import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/attempt_model.dart';
import '../services/attempt_service.dart';

final attemptRepositoryProvider = Provider<AttemptRepository>((ref) {
  final attemptService = ref.watch(attemptServiceProvider);
  return AttemptRepository(attemptService);
});

class AttemptRepository {
  final AttemptService _attemptService;

  AttemptRepository(this._attemptService);

  /// Start a new test attempt
  Future<int> startAttempt(int testId) async {
    final response = await _attemptService.startAttempt(testId);

    if (response.success && response.data != null) {
      return response.data!['attempt_id'] as int;
    } else {
      final errorMessage = response.message ?? 'Failed to start test';
      // Handle specific error cases
      if (response.message?.contains('limit reached') == true) {
        throw Exception('Free test limit reached. Please upgrade to premium.');
      }
      if (response.message?.contains('premium required') == true) {
        throw Exception('This test requires premium subscription.');
      }
      throw Exception(errorMessage);
    }
  }

  /// Submit test attempt
  Future<TestAttempt> submitAttempt({
    required int attemptId,
    required List<Map<String, dynamic>> answers,
    required int timeTaken,
  }) async {
    final response = await _attemptService.submitAttempt(
      attemptId: attemptId,
      answers: answers,
      timeTaken: timeTaken,
    );

    if (response.success && response.data != null) {
      final resultData = response.data!['result'] as Map<String, dynamic>;
      return TestAttempt.fromJson(resultData);
    } else {
      throw Exception(response.message ?? 'Failed to submit test');
    }
  }

  /// Get attempt history with pagination
  Future<Map<String, dynamic>> getAttemptHistory({int page = 1, int limit = 20}) async {
    final response = await _attemptService.getAttemptHistory(page: page, limit: limit);

    if (response.success && response.data != null) {
      final data = response.data!;
      final items = (data['items'] as List).map((e) => TestAttempt.fromJson(e)).toList();

      return {
        'items': items,
        'pagination': data['pagination'] ?? {},
      };
    } else {
      throw Exception(response.message ?? 'Failed to load test history');
    }
  }

  /// Get specific attempt details
  Future<TestAttempt> getAttemptDetail(int attemptId) async {
    final response = await _attemptService.getAttemptDetail(attemptId);

    if (response.success && response.data != null) {
      return TestAttempt.fromJson(response.data!);
    } else {
      throw Exception(response.message ?? 'Failed to load attempt details');
    }
  }

  /// Retake a test
  Future<int> retakeTest(int testId) async {
    final response = await _attemptService.retakeTest(testId);

    if (response.success && response.data != null) {
      return response.data!['attempt_id'] as int;
    } else {
      throw Exception(response.message ?? 'Failed to retake test');
    }
  }

  /// Get leaderboard
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    final response = await _attemptService.getLeaderboard();

    if (response.success && response.data != null) {
      return (response.data! as List).cast<Map<String, dynamic>>();
    } else {
      throw Exception(response.message ?? 'Failed to load leaderboard');
    }
  }
}