import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/test_model.dart';
import '../../../data/models/attempt_model.dart';
import '../../../data/models/question_model.dart';
import '../../../data/models/answer_model.dart';

// Available Tests Provider
final availableTestsProvider = FutureProvider<Map<String, List<Test>>>((ref) async {
  // TODO: Implement actual API call
  await Future.delayed(const Duration(seconds: 1)); // Simulate API delay

  return {
    'chapter': [
      Test(
        id: 1,
        testNumber: 'T1.1',
        testType: 'chapter',
        title: 'Chapter 1 - Basic Test',
        isFree: true,
        isPremium: false,
        createdAt: DateTime.now().toIso8601String(),
        chapterName: 'Chapter 1: The Values and Principles of the UK',
        questionCount: 24,
        canAccess: true,
        attemptCount: 2,
        bestScore: 85.0,
      ),
      Test(
        id: 2,
        testNumber: 'T1.2',
        testType: 'chapter',
        title: 'Chapter 1 - Advanced Test',
        isFree: false,
        isPremium: true,
        createdAt: DateTime.now().toIso8601String(),
        chapterName: 'Chapter 1: The Values and Principles of the UK',
        questionCount: 24,
        canAccess: false,
        attemptCount: 0,
      ),
    ],
    'comprehensive': [
      Test(
        id: 5,
        testNumber: 'COMP1',
        testType: 'comprehensive',
        title: 'Comprehensive Test 1',
        isFree: true,
        isPremium: false,
        createdAt: DateTime.now().toIso8601String(),
        questionCount: 24,
        canAccess: true,
        attemptCount: 0,
      ),
    ],
    'exam': [
      Test(
        id: 7,
        testNumber: 'EXAM1',
        testType: 'exam',
        title: 'Practice Exam 1',
        isFree: false,
        isPremium: true,
        createdAt: DateTime.now().toIso8601String(),
        questionCount: 24,
        canAccess: false,
        attemptCount: 0,
      ),
    ],
  };
});

// FIXED: Test Detail Provider - Return proper Test object with questions
final testDetailProvider = FutureProvider.family<TestWithQuestions, int>((ref, testId) async {
  // TODO: Implement actual API call
  await Future.delayed(const Duration(milliseconds: 500));

  // Create sample questions
  final questions = [
    Question(
      id: 1,
      testId: testId,
      questionId: 'Q1.1',
      questionText: 'What is the National Anthem of the UK?',
      questionType: 'radio',
      explanation: "The National Anthem of the UK is 'God Save the Queen'. It is played at important national occasions and at events attended by the Queen or the Royal Family.",
      answers: [
        const Answer(
          id: 1,
          questionId: 1,
          answerId: 'A',
          answerText: 'United we stand',
        ),
        const Answer(
          id: 2,
          questionId: 1,
          answerId: 'B',
          answerText: 'God Save the Queen',
          isCorrect: true,
        ),
        const Answer(
          id: 3,
          questionId: 1,
          answerId: 'C',
          answerText: 'God Save the UK',
        ),
        const Answer(
          id: 4,
          questionId: 1,
          answerId: 'D',
          answerText: 'Queen reign over the UK',
        ),
      ],
      createdAt: DateTime.now().toIso8601String(),
    ),
    Question(
      id: 2,
      testId: testId,
      questionId: 'Q1.2',
      questionText: 'Jane Austen is known for which of these TWO books?',
      questionType: 'checkbox',
      explanation: 'Jane Austen (1775-1817) was an English novelist. Her books include Pride and Prejudice and Sense and Sensibility. Her novels are concerned with marriage and family relationships. Many have been made into television programmes or films.',
      answers: [
        const Answer(
          id: 5,
          questionId: 2,
          answerId: 'A',
          answerText: 'Little Women',
        ),
        const Answer(
          id: 6,
          questionId: 2,
          answerId: 'B',
          answerText: 'Pride and Prejudice',
          isCorrect: true,
        ),
        const Answer(
          id: 7,
          questionId: 2,
          answerId: 'C',
          answerText: 'Great Expectations',
        ),
        const Answer(
          id: 8,
          questionId: 2,
          answerId: 'D',
          answerText: 'Sense and Sensibility',
          isCorrect: true,
        ),
      ],
      createdAt: DateTime.now().toIso8601String(),
    ),
  ];

  // Return proper Test object with questions
  return TestWithQuestions(
    id: testId,
    testNumber: 'T1.1',
    testType: 'chapter',
    title: 'Chapter 1 - Basic Test',
    isFree: true,
    isPremium: false,
    createdAt: DateTime.now().toIso8601String(),
    chapterName: 'Chapter 1: The Values and Principles of the UK',
    questionCount: questions.length,
    canAccess: true,
    attemptCount: 2,
    bestScore: 85.0,
    questions: questions,
  );
});

// Test Provider
final testProvider = StateNotifierProvider<TestNotifier, TestState>((ref) {
  return TestNotifier();
});

class TestState {
  final bool isLoading;
  final String? error;

  const TestState({
    this.isLoading = false,
    this.error,
  });

  TestState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return TestState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TestNotifier extends StateNotifier<TestState> {
  TestNotifier() : super(const TestState());

  Future<int> startAttempt(int testId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(isLoading: false);
      return 123; // Return attempt ID
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<int> submitAttempt({
    required int attemptId,
    required Map<int, List<String>> answers,
    required int timeTaken,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 2));

      state = state.copyWith(isLoading: false);
      return attemptId;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

// FIXED: Attempt Detail Provider - Return proper TestAttempt object
final attemptDetailProvider = FutureProvider.family<TestAttempt, int>((ref, attemptId) async {
  // TODO: Implement actual API call
  await Future.delayed(const Duration(milliseconds: 500));

  return TestAttempt(
    id: attemptId,
    userId: 1,
    testId: 1,
    score: 18,
    totalQuestions: 24,
    percentage: 75.0,
    timeTaken: 1800, // 30 minutes in seconds
    isPassed: true,
    startedAt: DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
    completedAt: DateTime.now().toIso8601String(),
    title: 'Chapter 1 - Basic Test',
    testNumber: 'T1.1',
    testType: 'chapter',
    chapterName: 'Chapter 1: The Values and Principles of the UK',
  );
});

// Test History Provider
final testHistoryProvider = FutureProvider<List<TestAttempt>>((ref) async {
  // TODO: Implement actual API call
  await Future.delayed(const Duration(seconds: 1));

  return [
    TestAttempt(
      id: 123,
      userId: 1,
      testId: 1,
      score: 18,
      totalQuestions: 24,
      percentage: 75.0,
      timeTaken: 1800,
      isPassed: true,
      startedAt: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      completedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)).toIso8601String(),
      title: 'Chapter 1 - Basic Test',
      testNumber: 'T1.1',
      testType: 'chapter',
      chapterName: 'Chapter 1: The Values and Principles of the UK',
    ),
    TestAttempt(
      id: 122,
      userId: 1,
      testId: 2,
      score: 20,
      totalQuestions: 24,
      percentage: 83.3,
      timeTaken: 1500,
      isPassed: true,
      startedAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      completedAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      title: 'Chapter 2 - Basic Test',
      testNumber: 'T2.1',
      testType: 'chapter',
      chapterName: 'Chapter 2: What is the UK?',
    ),
  ];
});

// FIXED: Create TestWithQuestions class
class TestWithQuestions extends Test {
  final List<Question> questions;

  const TestWithQuestions({
    required super.id,
    super.chapterId,
    required super.testNumber,
    required super.testType,
    super.title,
    super.url,
    required super.isFree,
    required super.isPremium,
    required super.createdAt,
    super.chapterName,
    super.questionCount,
    super.canAccess,
    super.attemptCount,
    super.bestScore,
    required this.questions,
  });
}