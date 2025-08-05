import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/AnswerSubmission.dart';
import '../data/models/TestAttempt.dart';
import '../data/models/TestResult.dart';
import '../data/models/UserAnswer.dart';
import '../data/requests/StartAttemptRequest.dart';
import '../data/requests/SubmitAttemptRequest.dart';
import '../services/api_service.dart';
import '../utils/logger.dart';
import 'TestState.dart';

// =============================================================================
// TEST NOTIFIER
// =============================================================================

class TestNotifier extends StateNotifier<TestState> {
  TestNotifier() : super(const TestState());

  // ==========================================================================
  // LOAD TESTS
  // ==========================================================================

  Future<void> loadAvailableTests() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final tests = await ApiService.getAvailableTests();

      state = state.copyWith(
        availableTests: tests,
        isLoading: false,
      );

      Logger.info('Loaded available tests: ${tests.keys.join(', ')}');
    } catch (e) {
      Logger.error('Failed to load available tests', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadFreeTests() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final tests = await ApiService.getFreeTests();

      state = state.copyWith(
        freeTests: tests,
        isLoading: false,
      );

      Logger.info('Loaded ${tests.length} free tests');
    } catch (e) {
      Logger.error('Failed to load free tests', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadTestDetails(int testId) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final test = await ApiService.getTest(testId);

      state = state.copyWith(
        currentTest: test,
        isLoading: false,
      );

      Logger.info('Loaded test details: ${test.title}');
    } catch (e) {
      Logger.error('Failed to load test details', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  //// Load chapter tests
  Future<void> loadTestsByChapter(int chapterId) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final tests = await ApiService.getTestsByChapter(chapterId);

      state = state.copyWith(
        chapterTests: tests,
        isLoading: false,
      );

      Logger.info('Loaded ${tests.length} tests for chapter $chapterId');
    } catch (e) {
      Logger.error('Failed to load chapter tests', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // ==========================================================================
  // TEST ATTEMPT MANAGEMENT
  // ==========================================================================

  Future<bool> startTest(int testId) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // Load test details first if not already loaded
      if (state.currentTest?.id != testId) {
        await loadTestDetails(testId);
      }

      // Start the attempt
      final request = StartAttemptRequest(testId: testId);
      final attempt = await ApiService.startAttempt(request);

      state = state.copyWith(
        currentAttempt: attempt,
        currentAnswers: [],
        currentQuestionIndex: 0,
        testStartTime: DateTime.now(),
        markedQuestions: [],
        isLoading: false,
      );

      Logger.info('Started test attempt: ${attempt.id}');
      return true;

    } catch (e) {
      Logger.error('Failed to start test', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<TestResult?> submitTest() async {
    if (!state.isTestInProgress || state.currentAttempt == null) {
      return null;
    }

    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final timeTaken = state.testStartTime != null
          ? DateTime.now().difference(state.testStartTime!).inSeconds
          : null;

      // Convert current answers to submission format
      final answers = state.currentAnswers.map((answer) {
        return AnswerSubmission(
          questionId: answer.questionId,
          selectedAnswerIds: answer.selectedAnswerIds,
        );
      }).toList();

      final request = SubmitAttemptRequest(
        attemptId: state.currentAttempt!.id,
        timeTaken: timeTaken,
        answers: answers,
      );

      final result = await ApiService.submitAttempt(request);

      // Clear current test state
      state = state.copyWith(
        isLoading: false,
        clearCurrentTest: true,
        clearTestStartTime: true,
        currentAttempt: null,
        currentAnswers: [],
        currentQuestionIndex: 0,
        markedQuestions: [],
      );

      Logger.info('Test submitted successfully');
      return result;

    } catch (e) {
      Logger.error('Failed to submit test', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // ==========================================================================
  // QUESTION NAVIGATION
  // ==========================================================================

  void goToQuestion(int index) {
    if (index >= 0 && index < state.totalQuestions) {
      state = state.copyWith(currentQuestionIndex: index);
    }
  }

  void nextQuestion() {
    if (!state.isLastQuestion) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
    }
  }

  void previousQuestion() {
    if (!state.isFirstQuestion) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1);
    }
  }

  // ==========================================================================
  // ANSWER MANAGEMENT
  // ==========================================================================

  void selectAnswer(int questionId, List<String> selectedAnswerIds) {
    final currentAnswers = List<UserAnswer>.from(state.currentAnswers);

    // Remove existing answer for this question
    currentAnswers.removeWhere((answer) => answer.questionId == questionId);

    // Add new answer
    if (selectedAnswerIds.isNotEmpty) {
      final newAnswer = UserAnswer(
        id: 0, // Will be set by server
        attemptId: state.currentAttempt?.id ?? 0,
        questionId: questionId,
        selectedAnswerIds: selectedAnswerIds,
        isCorrect: false, // Will be determined by server
        answeredAt: DateTime.now(),
      );

      currentAnswers.add(newAnswer);
    }

    state = state.copyWith(currentAnswers: currentAnswers);
    Logger.debug('Answer selected for question $questionId: $selectedAnswerIds');
  }

  void clearAnswer(int questionId) {
    final updatedAnswers = state.currentAnswers
        .where((answer) => answer.questionId != questionId)
        .toList();

    state = state.copyWith(currentAnswers: updatedAnswers);
  }

  // ==========================================================================
  // QUESTION MARKING
  // ==========================================================================

  void toggleQuestionMark(int questionIndex) {
    final markedQuestions = List<int>.from(state.markedQuestions);

    if (markedQuestions.contains(questionIndex)) {
      markedQuestions.remove(questionIndex);
    } else {
      markedQuestions.add(questionIndex);
    }

    state = state.copyWith(markedQuestions: markedQuestions);
  }

  void clearAllMarks() {
    state = state.copyWith(markedQuestions: []);
  }

  // ==========================================================================
  // STATE MANAGEMENT
  // ==========================================================================

  void clearCurrentTest() {
    state = state.copyWith(
      clearCurrentTest: true,
      clearTestStartTime: true,
      currentAttempt: null,
      currentAnswers: [],
      currentQuestionIndex: 0,
      markedQuestions: [],
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // ==========================================================================
  // ATTEMPT DETAILS
  // ==========================================================================

  Future<TestAttempt> getAttemptDetails(int attemptId) async {
    try {
      return await ApiService.getAttemptDetails(attemptId);
    } catch (e) {
      Logger.error('Failed to get attempt details', e);
      rethrow;
    }
  }

  // ==========================================================================
  // VALIDATION HELPERS
  // ==========================================================================

  bool canSubmitTest() {
    return state.isTestInProgress &&
        state.currentAnswers.isNotEmpty;
  }

  List<int> getUnansweredQuestions() {
    final answeredQuestionIds = state.currentAnswers
        .map((answer) => answer.questionId)
        .toSet();

    final unansweredQuestions = <int>[];

    for (int i = 0; i < state.totalQuestions; i++) {
      final question = state.currentTest!.questions[i];
      if (!answeredQuestionIds.contains(question.id)) {
        unansweredQuestions.add(i);
      }
    }

    return unansweredQuestions;
  }

  bool hasUnansweredQuestions() {
    return getUnansweredQuestions().isNotEmpty;
  }

  Duration? getElapsedTime() {
    if (state.testStartTime == null) return null;
    return DateTime.now().difference(state.testStartTime!);
  }

  Duration? getRemainingTime() {
    if (state.testStartTime == null) return null;

    final elapsed = getElapsedTime()!;
    final remaining = const Duration(minutes: 45) - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool isTimeUp() {
    final remaining = getRemainingTime();
    return remaining == null || remaining == Duration.zero;
  }
}