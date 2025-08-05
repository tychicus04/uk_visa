import '../data/models/Question.dart';
import '../data/models/Test.dart';
import '../data/models/TestAttempt.dart';
import '../data/models/UserAnswer.dart';

class TestState {
  final Map<String, List<Test>> availableTests;
  final List<Test> freeTests;
  final Test? currentTest;
  final TestAttempt? currentAttempt;
  final List<UserAnswer> currentAnswers;
  final int currentQuestionIndex;
  final bool isLoading;
  final String? error;
  final DateTime? testStartTime;
  final List<int> markedQuestions;
  final List<Test> chapterTests;

  const TestState({
    this.availableTests = const {},
    this.freeTests = const [],
    this.currentTest,
    this.currentAttempt,
    this.currentAnswers = const [],
    this.currentQuestionIndex = 0,
    this.isLoading = false,
    this.error,
    this.testStartTime,
    this.markedQuestions = const [],
    this.chapterTests = const [],
  });

  TestState copyWith({
    Map<String, List<Test>>? availableTests,
    List<Test>? freeTests,
    Test? currentTest,
    TestAttempt? currentAttempt,
    List<UserAnswer>? currentAnswers,
    int? currentQuestionIndex,
    bool? isLoading,
    String? error,
    DateTime? testStartTime,
    List<int>? markedQuestions,
    bool clearError = false,
    bool clearCurrentTest = false,
    bool clearTestStartTime = false,
    List<Test>? chapterTests,
  }) {
    return TestState(
      availableTests: availableTests ?? this.availableTests,
      freeTests: freeTests ?? this.freeTests,
      currentTest: clearCurrentTest ? null : (currentTest ?? this.currentTest),
      currentAttempt: currentAttempt ?? this.currentAttempt,
      currentAnswers: currentAnswers ?? this.currentAnswers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      testStartTime: clearTestStartTime ? null : (testStartTime ?? this.testStartTime),
      markedQuestions: markedQuestions ?? this.markedQuestions,
      chapterTests: chapterTests ?? this.chapterTests,
    );
  }

  bool get hasCurrentTest => currentTest != null;
  bool get hasCurrentAttempt => currentAttempt != null;
  bool get isTestInProgress => hasCurrentTest && hasCurrentAttempt && testStartTime != null;
  int get totalQuestions => currentTest?.questions.length ?? 0;
  bool get isLastQuestion => currentQuestionIndex >= totalQuestions - 1;
  bool get isFirstQuestion => currentQuestionIndex == 0;

  Question? get currentQuestion {
    if (!hasCurrentTest || totalQuestions == 0) return null;
    if (currentQuestionIndex >= totalQuestions) return null;
    return currentTest!.questions[currentQuestionIndex];
  }

  UserAnswer? getCurrentAnswer() {
    if (currentQuestion == null) return null;

    try {
      return currentAnswers.firstWhere(
            (answer) => answer.questionId == currentQuestion!.id,
      );
    } catch (e) {
      return null;
    }
  }

  bool isQuestionMarked(int questionIndex) {
    return markedQuestions.contains(questionIndex);
  }

  int get answeredQuestionsCount {
    return currentAnswers.length;
  }

  double get progressPercentage {
    if (totalQuestions == 0) return 0.0;
    return answeredQuestionsCount / totalQuestions;
  }
}