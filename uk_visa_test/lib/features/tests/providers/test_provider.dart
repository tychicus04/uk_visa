import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/attempt_model.dart';
import '../../../data/models/test_model.dart';
import '../../../data/repositories/attempt_repository.dart';
import '../../../data/repositories/test_repository.dart';
import '../../../data/states/TestState.dart';
import '../../../shared/providers/bilingual_provider.dart';

final availableTestsProvider = FutureProvider<Map<String, List<Test>>>((ref) async {
  try {
    print('🔄 Loading available tests...');

    final testRepository = ref.watch(testRepositoryProvider);
    final shouldShowVietnamese = ref.read(shouldShowVietnameseProvider);

    print('🌐 Vietnamese support: $shouldShowVietnamese');

    final result = await testRepository.getAvailableTests(
      includeVietnamese: shouldShowVietnamese,
    );

    // ✅ Detailed logging
    print('📊 Available tests loaded:');
    result.forEach((type, tests) {
      print('   $type: ${tests.length} tests');
      for (final test in tests.take(3)) { // Show first 3 of each type
        print('     - ${test.id}: ${test.displayTitle} (${test.testType})');
      }
      if (tests.length > 3) {
        print('     ... and ${tests.length - 3} more');
      }
    });

    final totalTests = result.values.fold<int>(0, (sum, list) => sum + list.length);
    print('🎯 Total: $totalTests tests across ${result.length} categories');

    return result;
  } catch (e, stackTrace) {
    print('💥 Failed to load available tests: $e');
    print('📚 Stack trace: $stackTrace');
    rethrow;
  }
});

final freeTestsProvider = FutureProvider<List<Test>>((ref) async {
  try {
    print('🔄 Loading free tests...');

    final testRepository = ref.watch(testRepositoryProvider);
    final shouldShowVietnamese = ref.read(shouldShowVietnameseProvider);
    final result = await testRepository.getFreeTests(
      includeVietnamese: shouldShowVietnamese,
    );

    print('✅ Free tests loaded: ${result.length} tests');
    return result;
  } catch (e) {
    print('💥 Failed to load free tests: $e');
    rethrow;
  }
});

final testDetailProvider = FutureProvider.family<Test, dynamic>((ref, testIdParam) async {
  try {
    print('🔄 Loading test detail for: $testIdParam');

    final testRepository = ref.watch(testRepositoryProvider);
    final testId = _convertToInt(testIdParam, 'testId');
    final shouldShowVietnamese = ref.read(shouldShowVietnameseProvider);
    final result = await testRepository.getTest(
      testId,
      includeVietnamese: shouldShowVietnamese,
    );

    print('✅ Test detail loaded: ${result.id} - ${result.displayTitle}');
    return result;
  } catch (e) {
    print('💥 Failed to load test $testIdParam: $e');
    rethrow;
  }
});

final testsByTypeProvider = FutureProvider.family<List<Test>, String>((ref, type) async {
  try {
    print('🔄 Loading tests by type: $type');

    final testRepository = ref.watch(testRepositoryProvider);
    final shouldShowVietnamese = ref.read(shouldShowVietnameseProvider);
    final result = await testRepository.getTestsByType(
      type,
      includeVietnamese: shouldShowVietnamese,
    );

    print('✅ Tests by type "$type" loaded: ${result.length} tests');
    return result;
  } catch (e) {
    print('💥 Failed to load tests by type "$type": $e');
    rethrow;
  }
});

final testsByChapterProvider = FutureProvider.family<List<Test>, dynamic>((ref, chapterIdParam) async {
  try {
    print('🔄 Loading tests by chapter: $chapterIdParam');

    final testRepository = ref.watch(testRepositoryProvider);
    final chapterId = _convertToInt(chapterIdParam, 'chapterId');
    final shouldShowVietnamese = ref.read(shouldShowVietnameseProvider);
    final result = await testRepository.getTestsByChapter(
      chapterId,
      includeVietnamese: shouldShowVietnamese,
    );

    print('✅ Tests for chapter $chapterId loaded: ${result.length} tests');
    return result;
  } catch (e) {
    print('💥 Failed to load tests for chapter $chapterIdParam: $e');
    rethrow;
  }
});

final searchTestsProvider = FutureProvider.family<List<Test>, Map<String, dynamic>>((ref, params) async {
  try {
    print('🔄 Searching tests with params: $params');

    final testRepository = ref.watch(testRepositoryProvider);

    int? chapterId;
    if (params['chapterId'] != null) {
      chapterId = _convertToInt(params['chapterId'], 'chapterId');
    }

    final shouldShowVietnamese = ref.read(shouldShowVietnameseProvider);
    final result = await testRepository.searchTests(
      query: params['query'] as String?,
      type: params['type'] as String?,
      chapterId: chapterId,
      includeVietnamese: shouldShowVietnamese,
    );

    print('✅ Search completed: ${result.length} tests found');
    return result;
  } catch (e) {
    print('💥 Failed to search tests: $e');
    rethrow;
  }
});

final testProvider = StateNotifierProvider<TestNotifier, TestState>(TestNotifier.new);

class TestNotifier extends StateNotifier<TestState> {

  TestNotifier(this.ref) : super(const TestState());
  final Ref ref;

  Future<String> startAttempt(testIdParam) async {
    print('🔄 Starting test attempt for: $testIdParam');
    state = state.copyWith(isLoading: true);

    try {
      final attemptRepository = ref.read(attemptRepositoryProvider);
      final testId = _convertToInt(testIdParam, 'testId');
      final attemptId = await attemptRepository.startAttempt(testId);
      final attemptIdString = attemptId.toString();

      state = state.copyWith(
        isLoading: false,
        currentAttemptId: attemptIdString,
      );

      print('✅ Test attempt started: $attemptIdString');
      return attemptIdString;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      print('💥 Failed to start test attempt: $e');
      rethrow;
    }
  }

  Future<String> submitAttempt({
    required attemptIdParam,
    required Map<String, List<String>> answers,
    required int timeTaken,
  }) async {
    print('🔄 Submitting test attempt: $attemptIdParam');
    state = state.copyWith(isLoading: true);

    try {
      final attemptRepository = ref.read(attemptRepositoryProvider);
      final attemptId = _convertToInt(attemptIdParam, 'attemptId');

      final apiAnswers = answers.entries.map((entry) {
        final questionId = _convertToInt(entry.key, 'questionId');
        return {
          'question_id': questionId,
          'selected_answer_ids': entry.value,
        };
      }).toList();

      final result = await attemptRepository.submitAttempt(
        attemptId: attemptId,
        answers: apiAnswers,
        timeTaken: timeTaken,
      );

      state = state.copyWith(
        isLoading: false,
        currentAttemptId: null,
      );

      // Refresh available tests to update attempt counts
      ref.invalidate(availableTestsProvider);

      // ✅ Return the original attemptId instead of result.id
      final attemptIdString = attemptId.toString();
      print('✅ Test attempt submitted successfully, returning attemptId: $attemptIdString');
      return attemptIdString;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      print('💥 Failed to submit test attempt: $e');
      rethrow;
    }
  }

  Future<String> retakeTest(testIdParam) async {
    print('🔄 Retaking test: $testIdParam');
    state = state.copyWith(isLoading: true);

    try {
      final attemptRepository = ref.read(attemptRepositoryProvider);
      final testId = _convertToInt(testIdParam, 'testId');
      final attemptId = await attemptRepository.retakeTest(testId);
      final attemptIdString = attemptId.toString();

      state = state.copyWith(
        isLoading: false,
        currentAttemptId: attemptIdString,
      );

      print('✅ Test retake started: $attemptIdString');
      return attemptIdString;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      print('💥 Failed to retake test: $e');
      rethrow;
    }
  }

  void clearCurrentAttempt() {
    state = state.copyWith();
  }

  void clearError() {
    state = state.copyWith();
  }
}

final attemptDetailProvider = FutureProvider.family<TestAttempt, dynamic>((ref, attemptIdParam) async {
  try {
    print('🔄 Loading attempt detail: $attemptIdParam');

    final attemptRepository = ref.watch(attemptRepositoryProvider);
    final attemptId = _convertToInt(attemptIdParam, 'attemptId');
    final result = await attemptRepository.getAttemptDetail(attemptId);

    print('✅ Attempt detail loaded: ${result.id}');
    return result;
  } catch (e) {
    print('💥 Failed to load attempt $attemptIdParam: $e');
    rethrow;
  }
});

final testHistoryProvider = FutureProvider.family<Map<String, dynamic>, Map<String, int>>((ref, params) async {
  try {
    print('🔄 Loading test history: page ${params['page']}, limit ${params['limit']}');

    final attemptRepository = ref.watch(attemptRepositoryProvider);

    final result = await attemptRepository.getAttemptHistory(
      page: params['page'] ?? 1,
      limit: params['limit'] ?? 20,
    );

    print('✅ Test history loaded: ${result['items']?.length ?? 0} attempts');
    return result;
  } catch (e) {
    print('💥 Failed to load test history: $e');
    rethrow;
  }
});

final leaderboardProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    print('🔄 Loading leaderboard...');

    final attemptRepository = ref.watch(attemptRepositoryProvider);
    final result = await attemptRepository.getLeaderboard();

    print('✅ Leaderboard loaded: ${result.length} entries');
    return result;
  } catch (e) {
    print('💥 Failed to load leaderboard: $e');
    rethrow;
  }
});

final recentAttemptsProvider = FutureProvider<List<TestAttempt>>((ref) async {
  try {
    print('🔄 Loading recent attempts...');

    final historyData = await ref.watch(testHistoryProvider({'page': 1, 'limit': 5}).future);
    final items = historyData['items'] as List<TestAttempt>? ?? [];

    print('✅ Recent attempts loaded: ${items.length}');
    return items;
  } catch (e) {
    print('💥 Failed to load recent attempts: $e');
    return [];
  }
});

final userTestStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    print('🔄 Calculating user test stats...');

    final historyData = await ref.watch(testHistoryProvider({'page': 1, 'limit': 100}).future);
    final attempts = historyData['items'] as List<TestAttempt>? ?? [];

    if (attempts.isEmpty) {
      return {
        'total_attempts': 0,
        'passed_attempts': 0,
        'average_score': 0.0,
        'best_score': 0.0,
        'total_time_spent': 0,
      };
    }

    final totalAttempts = attempts.length;
    final passedAttempts = attempts.where((a) => a.isPassed).length;
    final averageScore = attempts
        .where((a) => a.percentage != null)
        .map((a) => a.percentage!)
        .fold<double>(0, (sum, score) => sum + score) / totalAttempts;
    final bestScore = attempts
        .where((a) => a.percentage != null)
        .map((a) => a.percentage!)
        .fold<double>(0, (best, score) => score > best ? score : best);
    final totalTimeSpent = attempts
        .map((a) => a.timeTakenInt)
        .fold<int>(0, (sum, time) => sum + time);

    final stats = {
      'total_attempts': totalAttempts,
      'passed_attempts': passedAttempts,
      'average_score': averageScore,
      'best_score': bestScore,
      'total_time_spent': totalTimeSpent,
      'pass_rate': totalAttempts > 0 ? (passedAttempts / totalAttempts * 100) : 0.0,
    };

    print('✅ User stats calculated: $stats');
    return stats;
  } catch (e) {
    print('💥 Failed to calculate user stats: $e');
    return {
      'total_attempts': 0,
      'passed_attempts': 0,
      'average_score': 0.0,
      'best_score': 0.0,
      'total_time_spent': 0,
    };
  }
});

// ✅ Helper function for safe ID conversion
int _convertToInt(dynamic value, String fieldName) {
  if (value is int) return value;
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
  }

  print('⚠️ Warning: Invalid $fieldName: $value (${value.runtimeType})');
  throw ArgumentError('Invalid $fieldName: expected int or parseable string, got $value');
}

// ✅ Helper extension for backward compatibility
extension TestProviderHelpers on dynamic {
  /// Convert any ID parameter to int for API calls
  int toIntId([String fieldName = 'id']) => _convertToInt(this, fieldName);

  /// Convert any ID parameter to string for UI usage
  String toStringId() => this?.toString() ?? '0';
}