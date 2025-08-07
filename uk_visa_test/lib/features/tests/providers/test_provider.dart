// lib/features/tests/providers/test_provider.dart (Updated)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/test_model.dart';
import '../../../data/models/attempt_model.dart';
import '../../../data/repositories/test_repository.dart';
import '../../../data/repositories/attempt_repository.dart';

// Available Tests Provider (Real API)
final availableTestsProvider = FutureProvider<Map<String, List<Test>>>((ref) async {
  final testRepository = ref.watch(testRepositoryProvider);
  return await testRepository.getAvailableTests();
});

// Free Tests Provider
final freeTestsProvider = FutureProvider<List<Test>>((ref) async {
  final testRepository = ref.watch(testRepositoryProvider);
  return await testRepository.getFreeTests();
});

// Test Detail Provider (Real API)
final testDetailProvider = FutureProvider.family<Test, int>((ref, testId) async {
  final testRepository = ref.watch(testRepositoryProvider);
  return await testRepository.getTest(testId);
});

// Tests by Type Provider
final testsByTypeProvider = FutureProvider.family<List<Test>, String>((ref, type) async {
  final testRepository = ref.watch(testRepositoryProvider);
  return await testRepository.getTestsByType(type);
});

// Tests by Chapter Provider
final testsByChapterProvider = FutureProvider.family<List<Test>, int>((ref, chapterId) async {
  final testRepository = ref.watch(testRepositoryProvider);
  return await testRepository.getTestsByChapter(chapterId);
});

// Search Tests Provider
final searchTestsProvider = FutureProvider.family<List<Test>, Map<String, dynamic>>((ref, params) async {
  final testRepository = ref.watch(testRepositoryProvider);
  return await testRepository.searchTests(
    query: params['query'] as String?,
    type: params['type'] as String?,
    chapterId: params['chapterId'] as int?,
  );
});

// Test Actions Provider
final testProvider = StateNotifierProvider<TestNotifier, TestState>((ref) {
  return TestNotifier(ref);
});

class TestState {
  final bool isLoading;
  final String? error;
  final int? currentAttemptId;

  const TestState({
    this.isLoading = false,
    this.error,
    this.currentAttemptId,
  });

  TestState copyWith({
    bool? isLoading,
    String? error,
    int? currentAttemptId,
  }) {
    return TestState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentAttemptId: currentAttemptId ?? this.currentAttemptId,
    );
  }
}

class TestNotifier extends StateNotifier<TestState> {
  final Ref ref;

  TestNotifier(this.ref) : super(const TestState());

  Future<int> startAttempt(int testId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final attemptRepository = ref.read(attemptRepositoryProvider);
      final attemptId = await attemptRepository.startAttempt(testId);

      state = state.copyWith(
        isLoading: false,
        currentAttemptId: attemptId,
      );
      return attemptId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<TestAttempt> submitAttempt({
    required int attemptId,
    required Map<int, List<String>> answers,
    required int timeTaken,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final attemptRepository = ref.read(attemptRepositoryProvider);

      // Convert answers to API format
      final apiAnswers = answers.entries.map((entry) => {
        'question_id': entry.key,
        'selected_answer_ids': entry.value,
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

      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<int> retakeTest(int testId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final attemptRepository = ref.read(attemptRepositoryProvider);
      final attemptId = await attemptRepository.retakeTest(testId);

      state = state.copyWith(
        isLoading: false,
        currentAttemptId: attemptId,
      );
      return attemptId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }
}

// Attempt Detail Provider (Real API)
final attemptDetailProvider = FutureProvider.family<TestAttempt, int>((ref, attemptId) async {
  final attemptRepository = ref.watch(attemptRepositoryProvider);
  return await attemptRepository.getAttemptDetail(attemptId);
});

// Test History Provider (Real API)
final testHistoryProvider = FutureProvider.family<Map<String, dynamic>, Map<String, int>>((ref, params) async {
  final attemptRepository = ref.watch(attemptRepositoryProvider);
  return await attemptRepository.getAttemptHistory(
    page: params['page'] ?? 1,
    limit: params['limit'] ?? 20,
  );
});

// Leaderboard Provider
final leaderboardProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final attemptRepository = ref.watch(attemptRepositoryProvider);
  return await attemptRepository.getLeaderboard();
});