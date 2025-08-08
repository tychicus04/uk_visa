// lib/features/tests/providers/test_provider.dart - UPDATED FOR STRING IDs
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/test_model.dart';
import '../../../data/models/attempt_model.dart';
import '../../../data/repositories/test_repository.dart';
import '../../../data/repositories/attempt_repository.dart';

// ✅ Available Tests Provider (Real API)
final availableTestsProvider = FutureProvider<Map<String, List<Test>>>((ref) async {
  try {
    final testRepository = ref.watch(testRepositoryProvider);
    final result = await testRepository.getAvailableTests();
    print('✅ Available tests loaded: ${result.keys}');
    return result;
  } catch (e) {
    print('❌ Failed to load available tests: $e');
    rethrow;
  }
});

// ✅ Free Tests Provider
final freeTestsProvider = FutureProvider<List<Test>>((ref) async {
  try {
    final testRepository = ref.watch(testRepositoryProvider);
    final result = await testRepository.getFreeTests();
    print('✅ Free tests loaded: ${result.length}');
    return result;
  } catch (e) {
    print('❌ Failed to load free tests: $e');
    rethrow;
  }
});

// ✅ Test Detail Provider - Handle both int and string IDs
final testDetailProvider = FutureProvider.family<Test, dynamic>((ref, testIdParam) async {
  try {
    final testRepository = ref.watch(testRepositoryProvider);

    // ✅ Convert to int for API calls regardless of input type
    final testId = _convertToInt(testIdParam, 'testId');

    print('🔍 Loading test detail for ID: $testIdParam → $testId');
    final result = await testRepository.getTest(testId);
    print('✅ Test loaded: ${result.displayTitle}');
    return result;
  } catch (e) {
    print('❌ Failed to load test $testIdParam: $e');
    rethrow;
  }
});

// ✅ Tests by Type Provider
final testsByTypeProvider = FutureProvider.family<List<Test>, String>((ref, type) async {
  try {
    final testRepository = ref.watch(testRepositoryProvider);
    final result = await testRepository.getTestsByType(type);
    print('✅ Tests by type "$type" loaded: ${result.length}');
    return result;
  } catch (e) {
    print('❌ Failed to load tests by type "$type": $e');
    rethrow;
  }
});

// ✅ Tests by Chapter Provider - Handle both int and string chapter IDs
final testsByChapterProvider = FutureProvider.family<List<Test>, dynamic>((ref, chapterIdParam) async {
  try {
    final testRepository = ref.watch(testRepositoryProvider);

    // ✅ Convert to int for API calls
    final chapterId = _convertToInt(chapterIdParam, 'chapterId');

    print('🔍 Loading tests for chapter: $chapterIdParam → $chapterId');
    final result = await testRepository.getTestsByChapter(chapterId);
    print('✅ Chapter tests loaded: ${result.length}');
    return result;
  } catch (e) {
    print('❌ Failed to load tests for chapter $chapterIdParam: $e');
    rethrow;
  }
});

// ✅ Search Tests Provider - Handle dynamic chapter ID
final searchTestsProvider = FutureProvider.family<List<Test>, Map<String, dynamic>>((ref, params) async {
  try {
    final testRepository = ref.watch(testRepositoryProvider);

    // ✅ Convert chapter ID if provided
    int? chapterId;
    if (params['chapterId'] != null) {
      chapterId = _convertToInt(params['chapterId'], 'chapterId');
    }

    final result = await testRepository.searchTests(
      query: params['query'] as String?,
      type: params['type'] as String?,
      chapterId: chapterId,
    );

    print('✅ Search results: ${result.length} tests');
    return result;
  } catch (e) {
    print('❌ Failed to search tests: $e');
    rethrow;
  }
});

// ✅ Test Actions Provider
final testProvider = StateNotifierProvider<TestNotifier, TestState>((ref) {
  return TestNotifier(ref);
});

// ✅ Updated TestState with String ID support
class TestState {
  final bool isLoading;
  final String? error;
  final String? currentAttemptId; // ✅ Changed to String

  const TestState({
    this.isLoading = false,
    this.error,
    this.currentAttemptId,
  });

  TestState copyWith({
    bool? isLoading,
    String? error,
    String? currentAttemptId,
  }) {
    return TestState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentAttemptId: currentAttemptId ?? this.currentAttemptId,
    );
  }

  // ✅ Helper to get int ID when needed for API calls
  int? get currentAttemptIdInt =>
      currentAttemptId != null ? int.tryParse(currentAttemptId!) : null;
}

// ✅ Updated TestNotifier with String/Int conversion support
class TestNotifier extends StateNotifier<TestState> {
  final Ref ref;

  TestNotifier(this.ref) : super(const TestState());

  // ✅ Start Attempt - Handle both string and int test IDs
  Future<String> startAttempt(dynamic testIdParam) async {
    state = state.copyWith(isLoading: true, error: null);
    print('🎯 Starting attempt for test: $testIdParam (${testIdParam.runtimeType})');

    try {
      final attemptRepository = ref.read(attemptRepositoryProvider);
      // ✅ Convert test ID to int for API call

      // ✅ Convert to int for API call
      final testId = _convertToInt(testIdParam, 'testId');

      print('📡 API call: startAttempt($testId)');
      final attemptId = await attemptRepository.startAttempt(testId);

      // ✅ Store as string for consistency
      final attemptIdString = attemptId.toString();

      state = state.copyWith(
        isLoading: false,
        currentAttemptId: attemptIdString,
      );

      print('✅ Attempt started successfully: $attemptIdString');
      return attemptIdString;
    } catch (e) {
      print('❌ Start attempt failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  // ✅ Submit Attempt - Handle String question IDs and answer IDs
  Future<String> submitAttempt({
    required dynamic attemptIdParam,
    required Map<String, List<String>> answers, // ✅ Changed to String keys
    required int timeTaken,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    print('📝 Submitting attempt: $attemptIdParam');
    print('📊 Answers: ${answers.length} questions answered');

    try {
      final attemptRepository = ref.read(attemptRepositoryProvider);

      // ✅ Convert attempt ID to int for API
      final attemptId = _convertToInt(attemptIdParam, 'attemptId');

      // ✅ Convert string question IDs to int for API format
      final apiAnswers = answers.entries.map((entry) {
        final questionId = _convertToInt(entry.key, 'questionId');
        return {
          'question_id': questionId,
          'selected_answer_ids': entry.value,
        };
      }).toList();

      print('📡 API call: submitAttempt(id: $attemptId, answers: ${apiAnswers.length}, time: ${timeTaken}s)');

      final result = await attemptRepository.submitAttempt(
        attemptId: attemptId,
        answers: apiAnswers,
        timeTaken: timeTaken,
      );

      state = state.copyWith(
        isLoading: false,
        currentAttemptId: null,
      );

      // ✅ Refresh available tests to update attempt counts
      ref.invalidate(availableTestsProvider);

      print('✅ Attempt submitted successfully - Score: ${result.scoreDisplay}');
      return result.id;
    } catch (e) {
      print('❌ Submit attempt failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  // ✅ Retake Test - Handle dynamic test ID
  Future<String> retakeTest(dynamic testIdParam) async {
    state = state.copyWith(isLoading: true, error: null);
    print('🔄 Retaking test: $testIdParam');

    try {
      final attemptRepository = ref.read(attemptRepositoryProvider);

      // ✅ Convert to int for API call
      final testId = _convertToInt(testIdParam, 'testId');

      print('📡 API call: retakeTest($testId)');
      final attemptId = await attemptRepository.retakeTest(testId);

      // ✅ Store as string for consistency
      final attemptIdString = attemptId.toString();

      state = state.copyWith(
        isLoading: false,
        currentAttemptId: attemptIdString,
      );

      print('✅ Test retake started: $attemptIdString');
      return attemptIdString;
    } catch (e) {
      print('❌ Retake test failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  // ✅ Clear current attempt
  void clearCurrentAttempt() {
    state = state.copyWith(currentAttemptId: null);
    print('🧹 Current attempt cleared');
  }

  // ✅ Clear error state
  void clearError() {
    state = state.copyWith(error: null);
    print('🧹 Error state cleared');
  }
}

// ✅ Attempt Detail Provider - Handle dynamic attempt ID
final attemptDetailProvider = FutureProvider.family<TestAttempt, dynamic>((ref, attemptIdParam) async {
  try {
    final attemptRepository = ref.watch(attemptRepositoryProvider);

    // ✅ Convert to int for API call
    final attemptId = _convertToInt(attemptIdParam, 'attemptId');

    print('🔍 Loading attempt detail: $attemptIdParam → $attemptId');
    final result = await attemptRepository.getAttemptDetail(attemptId);
    print('✅ Attempt detail loaded: ${result.displayTitle}');
    return result;
  } catch (e) {
    print('❌ Failed to load attempt $attemptIdParam: $e');
    rethrow;
  }
});

// ✅ Test History Provider
final testHistoryProvider = FutureProvider.family<Map<String, dynamic>, Map<String, int>>((ref, params) async {
  try {
    final attemptRepository = ref.watch(attemptRepositoryProvider);

    final result = await attemptRepository.getAttemptHistory(
      page: params['page'] ?? 1,
      limit: params['limit'] ?? 20,
    );

    print('✅ Test history loaded: ${result['items']?.length ?? 0} attempts');
    return result;
  } catch (e) {
    print('❌ Failed to load test history: $e');
    rethrow;
  }
});

// ✅ Leaderboard Provider
final leaderboardProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final attemptRepository = ref.watch(attemptRepositoryProvider);
    final result = await attemptRepository.getLeaderboard();
    print('✅ Leaderboard loaded: ${result.length} entries');
    return result;
  } catch (e) {
    print('❌ Failed to load leaderboard: $e');
    rethrow;
  }
});

// ✅ Recent Attempts Provider (bonus)
final recentAttemptsProvider = FutureProvider<List<TestAttempt>>((ref) async {
  try {
    final historyData = await ref.watch(testHistoryProvider({'page': 1, 'limit': 5}).future);
    final items = historyData['items'] as List<TestAttempt>? ?? [];
    print('✅ Recent attempts loaded: ${items.length}');
    return items;
  } catch (e) {
    print('❌ Failed to load recent attempts: $e');
    return [];
  }
});

// ✅ User Test Stats Provider (bonus)
final userTestStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
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
    print('❌ Failed to calculate user stats: $e');
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