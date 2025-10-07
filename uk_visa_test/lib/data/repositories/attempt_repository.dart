import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/attempt_model.dart';
import '../services/attempt_service.dart';
import '../services/offline_attempt_service.dart';

final attemptRepositoryProvider = Provider<AttemptRepository>((ref) {
  final attemptService = ref.watch(attemptServiceProvider);
  return AttemptRepository(attemptService);
});

class AttemptRepository {
  final OfflineAttemptService _attemptService;

  AttemptRepository(this._attemptService);

  Future<String> startAttempt(int testId) async {
    try {
      print('🔄 Repository: Starting attempt for test $testId');

      final response = await _attemptService.startAttempt(testId);

      if (response.success && response.data != null) {
        final attemptIdRaw = response.data!['attempt_id'];
        final attemptId = attemptIdRaw?.toString() ?? '0';

        print('✅ Repository: Started attempt $attemptId for test $testId');
        return attemptId;
      } else {
        final errorMessage = response.message ?? 'Failed to start test';
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

  Future<TestAttempt> submitAttempt({
    required int attemptId,
    required List<Map<String, dynamic>> answers,
    required int timeTaken,
  }) async {
    try {
      final response = await _attemptService.submitAttempt(
        attemptId: attemptId,
        answers: answers,
        timeTaken: timeTaken,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final resultData = data['result'] as Map<String, dynamic>;

        final enhancedResultData = Map<String, dynamic>.from(resultData);
        enhancedResultData['id'] = attemptId.toString();
        enhancedResultData['attempt_id'] = attemptId.toString();

        if (data['test'] != null) {
          final testData = data['test'] as Map<String, dynamic>;
          enhancedResultData['title'] = testData['title'];
          enhancedResultData['test_number'] = testData['test_number'];
        }
        return TestAttempt.fromJson(enhancedResultData);
      } else {
        throw Exception(response.message ?? 'Failed to submit test');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAttemptHistory({
    int page = 1,
    int limit = 20,
    String? secondaryLanguage,
    bool includeVietnamese = false,
  }) async {
    try {

      final response = await _attemptService.getAttemptHistory(
        page: page,
        limit: limit,
        secondaryLanguage: secondaryLanguage,
        includeVietnamese: includeVietnamese,
      );
      if (response.success && response.data != null) {
        final data = response.data!;
        final items = (data['items'] as List).map((e) => TestAttempt.fromJson(e)).toList();

        return {
          'items': items,
          'pagination': data['pagination'] ?? {},
          'language_info': data['language_info'] ?? {},
        };
      } else {
        throw Exception(response.message ?? 'Failed to load test history');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<TestAttempt> getAttemptDetail(
      int attemptId, {
        String? secondaryLanguage,
        bool includeVietnamese = false, 
      }) async {
    try {
      final response = await _attemptService.getAttemptDetail(
        attemptId,
        secondaryLanguage: secondaryLanguage,
        includeVietnamese: includeVietnamese,
      );

      if (response.success && response.data != null) {
        final attempt = TestAttempt.fromJson(response.data!);
        if (secondaryLanguage != null) {
          final answers = attempt.answers ?? [];
          var translatedQuestions = 0;
          var translatedAnswers = 0;

          for (final answer in answers) {
            if (answer.hasQuestionTranslation(secondaryLanguage)) {
              translatedQuestions++;
            }
            final answerDetails = answer.answerDetails ?? [];
            for (final detail in answerDetails) {
              if (detail.hasAnswerTranslation(secondaryLanguage)) {
                translatedAnswers++;
              }
            }
          }

        } else if (includeVietnamese) {
        }

        return attempt;
      } else {
        throw Exception(response.message ?? 'Failed to load attempt details');
      }
    } catch (e) {
      rethrow;
    }
  }
  Future<int> retakeTest(int testId) async {
    try {
      print('🔄 Repository: Retaking test $testId');

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

  /// ✅ ENHANCED: Get leaderboard with dynamic multi-language support
  Future<List<Map<String, dynamic>>> getLeaderboard({
    String? secondaryLanguage,
    bool includeVietnamese = false, // Backward compatibility
  }) async {
    try {
      print('🔄 Repository: Loading leaderboard (Language: ${secondaryLanguage ?? 'none'})');

      final response = await _attemptService.getLeaderboard(
        secondaryLanguage: secondaryLanguage,
        includeVietnamese: includeVietnamese,
      );

      if (response.success && response.data != null) {
        final leaderboard = (response.data! as List).cast<Map<String, dynamic>>();
        print('✅ Repository: Loaded leaderboard with ${leaderboard.length} entries (Language: ${secondaryLanguage ?? 'none'})');
        return leaderboard;
      } else {
        throw Exception(response.message ?? 'Failed to load leaderboard');
      }
    } catch (e) {
      print('❌ Repository error in getLeaderboard: $e');
      rethrow;
    }
  }

  /// 🆕 NEW: Get user statistics with language support
  Future<Map<String, dynamic>> getUserStats({
    String? secondaryLanguage,
    bool includeVietnamese = false,
  }) async {
    try {
      print('🔄 Repository: Loading user statistics (Language: ${secondaryLanguage ?? 'none'})');

      // Get recent attempts with language support
      final historyData = await getAttemptHistory(
        page: 1,
        limit: 100, // Get more data for better statistics
        secondaryLanguage: secondaryLanguage,
        includeVietnamese: includeVietnamese,
      );

      final attempts = historyData['items'] as List<TestAttempt>? ?? [];

      if (attempts.isEmpty) {
        return {
          'total_attempts': 0,
          'passed_attempts': 0,
          'average_score': 0.0,
          'best_score': 0.0,
          'total_time_spent': 0,
          'pass_rate': 0.0,
          'language_info': historyData['language_info'],
        };
      }

      final totalAttempts = attempts.length;
      final passedAttempts = attempts.where((a) => a.isPassed).length;
      final validAttempts = attempts.where((a) => a.percentage != null).toList();

      final averageScore = validAttempts.isNotEmpty
          ? validAttempts.map((a) => a.percentage!).reduce((a, b) => a + b) / validAttempts.length
          : 0.0;

      final bestScore = validAttempts.isNotEmpty
          ? validAttempts.map((a) => a.percentage!).reduce((a, b) => a > b ? a : b)
          : 0.0;

      final totalTimeSpent = attempts
          .map((a) => a.timeTakenInt)
          .reduce((a, b) => a + b);

      final stats = {
        'total_attempts': totalAttempts,
        'passed_attempts': passedAttempts,
        'average_score': averageScore,
        'best_score': bestScore,
        'total_time_spent': totalTimeSpent,
        'pass_rate': totalAttempts > 0 ? (passedAttempts / totalAttempts * 100) : 0.0,
        'recent_attempts': attempts.take(5).toList(),
        'language_info': historyData['language_info'],
      };

      print('✅ Repository: User stats calculated with language support: ${stats.keys}');
      return stats;
    } catch (e) {
      print('❌ Repository error in getUserStats: $e');
      rethrow;
    }
  }
}