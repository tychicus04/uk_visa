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
  Future<String> startAttempt(int testId) async {
    try {
      print('📄 Repository: Starting attempt for test $testId');

      final response = await _attemptService.startAttempt(testId);

      if (response.success && response.data != null) {
        final attemptIdRaw = response.data!['attempt_id'];
        final attemptId = attemptIdRaw?.toString() ?? '0';

        print('✅ Repository: Started attempt $attemptId for test $testId');
        return attemptId;
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
    } catch (e) {
      print('❌ Repository error in startAttempt($testId): $e');
      rethrow;
    }
  }

  /// Submit test attempt
  Future<TestAttempt> submitAttempt({
    required int attemptId,
    required List<Map<String, dynamic>> answers,
    required int timeTaken,
  }) async {
    try {
      print('📄 Repository: Submitting attempt $attemptId with ${answers.length} answers');

      final response = await _attemptService.submitAttempt(
        attemptId: attemptId,
        answers: answers,
        timeTaken: timeTaken,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        print('📊 Submit response data keys: ${data.keys}');

        // ✅ Parse the result data and add attemptId
        final resultData = data['result'] as Map<String, dynamic>;

        // ✅ Add the attemptId to result data since API doesn't return it
        final enhancedResultData = Map<String, dynamic>.from(resultData);
        enhancedResultData['id'] = attemptId.toString();
        enhancedResultData['attempt_id'] = attemptId.toString();

        // ✅ Add test info if available
        if (data['test'] != null) {
          final testData = data['test'] as Map<String, dynamic>;
          enhancedResultData['title'] = testData['title'];
          enhancedResultData['test_number'] = testData['test_number'];
        }

        print('✅ Repository: Enhanced result data with attempt_id: $attemptId');
        return TestAttempt.fromJson(enhancedResultData);
      } else {
        throw Exception(response.message ?? 'Failed to submit test');
      }
    } catch (e) {
      print('❌ Repository error in submitAttempt($attemptId): $e');
      rethrow;
    }
  }

  /// Get attempt history with pagination
  Future<Map<String, dynamic>> getAttemptHistory({int page = 1, int limit = 20}) async {
    try {
      print('📄 Repository: Loading attempt history page $page, limit $limit');

      final response = await _attemptService.getAttemptHistory(page: page, limit: limit);

      if (response.success && response.data != null) {
        final data = response.data!;
        final items = (data['items'] as List).map((e) => TestAttempt.fromJson(e)).toList();

        print('✅ Repository: Loaded ${items.length} attempts from history');
        return {
          'items': items,
          'pagination': data['pagination'] ?? {},
        };
      } else {
        throw Exception(response.message ?? 'Failed to load test history');
      }
    } catch (e) {
      print('❌ Repository error in getAttemptHistory: $e');
      rethrow;
    }
  }

  /// ✅ UPDATED: Get specific attempt details with Vietnamese support
  Future<TestAttempt> getAttemptDetail(
      int attemptId, {
        bool includeVietnamese = false,
      }) async {
    try {
      print('📄 Repository: Loading attempt detail for $attemptId (Vietnamese: $includeVietnamese)');

      final response = await _attemptService.getAttemptDetail(
        attemptId,
        includeVietnamese: includeVietnamese,
      );

      if (response.success && response.data != null) {
        final attempt = TestAttempt.fromJson(response.data!);

        print('✅ Repository: Loaded attempt detail: ${attempt.id}');
        if (includeVietnamese) {
          print('🇻🇳 Repository: Vietnamese support enabled for attempt review');
        }

        return attempt;
      } else {
        print('❌ Repository: Failed to load attempt $attemptId - ${response.message}');
        throw Exception(response.message ?? 'Failed to load attempt details');
      }
    } catch (e) {
      print('❌ Repository error in getAttemptDetail($attemptId): $e');
      rethrow;
    }
  }

  /// Retake a test
  Future<int> retakeTest(int testId) async {
    try {
      print('📄 Repository: Retaking test $testId');

      final response = await _attemptService.retakeTest(testId);

      if (response.success && response.data != null) {
        final attemptIdRaw = response.data!['attempt_id'];
        final attemptId = attemptIdRaw is int
            ? attemptIdRaw
            : int.tryParse(attemptIdRaw?.toString() ?? '') ?? 0;

        print('✅ Repository: Retake started with attempt $attemptId');
        return attemptId;
      } else {
        throw Exception(response.message ?? 'Failed to retake test');
      }
    } catch (e) {
      print('❌ Repository error in retakeTest($testId): $e');
      rethrow;
    }
  }

  /// Get leaderboard
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      print('📄 Repository: Loading leaderboard');

      final response = await _attemptService.getLeaderboard();

      if (response.success && response.data != null) {
        final leaderboard = (response.data! as List).cast<Map<String, dynamic>>();
        print('✅ Repository: Loaded leaderboard with ${leaderboard.length} entries');
        return leaderboard;
      } else {
        throw Exception(response.message ?? 'Failed to load leaderboard');
      }
    } catch (e) {
      print('❌ Repository error in getLeaderboard: $e');
      rethrow;
    }
  }
}