import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/Question.dart';
import '../../providers/TestState.dart';
import '../../providers/app_providers.dart';
import '../../providers/test_notifier.dart';
import '../../data/models/Test.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

class TestTakingScreen extends ConsumerStatefulWidget {
  final int testId;
  final int? attemptId;

  const TestTakingScreen({
    super.key,
    required this.testId,
    this.attemptId,
  });

  @override
  ConsumerState<TestTakingScreen> createState() => _TestTakingScreenState();
}

class _TestTakingScreenState extends ConsumerState<TestTakingScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  bool _showReviewPanel = false;
  late AnimationController _progressAnimationController;
  late AnimationController _slideAnimationController;

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );
    _slideAnimationController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _progressAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime = Duration(seconds: _elapsedTime.inSeconds + 1);
      });

      // Auto-submit if time is up (45 minutes)
      if (_elapsedTime.inMinutes >= 45) {
        _timer?.cancel();
        _submitTest(autoSubmit: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final testState = ref.watch(testNotifierProvider);

    if (!testState.isTestInProgress) {
      return const Scaffold(
        body: Center(
          child: LoadingWidget(message: 'Loading test...'),
        ),
      );
    }

    final test = testState.currentTest!;
    final currentQuestion = testState.currentQuestion;

    if (currentQuestion == null) {
      return const Scaffold(
        body: ErrorDisplayWidget(message: 'No questions available'),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (_) => _showExitConfirmation(),
      child: Scaffold(
        appBar: _buildAppBar(test, testState),
        body: Column(
          children: [
            // Progress Bar
            _buildProgressBar(testState),

            // Timer Bar
            _buildTimerBar(),

            // Question Content
            Expanded(
              child: Stack(
                children: [
                  // Main Question View
                  _buildQuestionView(testState, currentQuestion),

                  // Review Panel
                  if (_showReviewPanel)
                    _buildReviewPanel(testState),
                ],
              ),
            ),

            // Navigation Bar
            _buildNavigationBar(testState),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Test test, TestState testState) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      title: Text('${test.testNumber} - Q${testState.currentQuestionIndex + 1}'),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: _showExitConfirmation,
      ),
      actions: [
        // Review Button
        IconButton(
          icon: Icon(_showReviewPanel ? Icons.quiz : Icons.list),
          onPressed: _toggleReviewPanel,
        ),

        // Submit Button
        TextButton(
          onPressed: _showSubmitConfirmation,
          child: Text(
            l10n.submitTest,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget _buildProgressBar(TestState testState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${testState.answeredQuestionsCount}/${testState.totalQuestions}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          AnimatedBuilder(
            animation: _progressAnimationController,
            builder: (context, child) {
              return LinearPercentIndicator(
                padding: EdgeInsets.zero,
                lineHeight: 6.0,
                percent: (testState.progressPercentage * _progressAnimationController.value).clamp(0.0, 1.0),
                backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                progressColor: Theme.of(context).colorScheme.primary,
                barRadius: const Radius.circular(3),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBar() {
    final remainingTime = const Duration(minutes: 45) - _elapsedTime;
    final isUrgent = remainingTime.inMinutes < 10;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isUrgent ? Colors.red.withOpacity(0.1) : Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            size: 16,
            color: isUrgent ? Colors.red : Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: 8),
          Text(
            'Time Remaining: ${_formatDuration(remainingTime)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isUrgent ? Colors.red : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            'Elapsed: ${_formatDuration(_elapsedTime)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionView(TestState testState, Question question) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.questionNumber(testState.currentQuestionIndex + 1),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Mark for Review Button
                    IconButton(
                      onPressed: () => _toggleQuestionMark(testState.currentQuestionIndex),
                      icon: Icon(
                        testState.isQuestionMarked(testState.currentQuestionIndex)
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: testState.isQuestionMarked(testState.currentQuestionIndex)
                            ? Colors.orange
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      tooltip: l10n.markForReview,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Question Text
                Text(
                  question.questionText,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                // Question Type Hint
                Text(
                  question.isRadio ? l10n.selectAnswer : l10n.selectAnswers,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Answer Options
          _buildAnswerOptions(question, testState),

          // Clear Selection Button
          if (testState.getCurrentAnswer() != null) ...[
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => _clearAnswer(question.id),
                child: Text(l10n.clearSelection),
              ),
            ),
          ],

          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(Question question, TestState testState) {
    final currentAnswer = testState.getCurrentAnswer();
    final selectedAnswerIds = currentAnswer?.selectedAnswerIds ?? [];

    return Column(
      children: question.answers.map((answer) {
        final isSelected = selectedAnswerIds.contains(answer.answerId);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _selectAnswer(question, answer.answerId),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Selection Indicator
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: question.isRadio ? BoxShape.circle : BoxShape.rectangle,
                      borderRadius: question.isRadio ? null : BorderRadius.circular(4),
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                      question.isRadio ? Icons.circle : Icons.check,
                      color: Colors.white,
                      size: 14,
                    )
                        : null,
                  ),

                  const SizedBox(width: 12),

                  // Answer Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                answer.answerId,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          answer.answerText,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewPanel(TestState testState) {
    return Positioned.fill(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            // Panel Header
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Question Review',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _toggleReviewPanel,
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),

            // Question Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: testState.totalQuestions,
                  itemBuilder: (context, index) {
                    return _buildQuestionGridItem(index, testState);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionGridItem(int index, TestState testState) {
    final isCurrentQuestion = index == testState.currentQuestionIndex;
    final isAnswered = testState.currentAnswers.any(
          (answer) => answer.questionId == testState.currentTest!.questions[index].id,
    );
    final isMarked = testState.isQuestionMarked(index);

    Color backgroundColor;
    Color textColor;

    if (isCurrentQuestion) {
      backgroundColor = Theme.of(context).colorScheme.primary;
      textColor = Colors.white;
    } else if (isAnswered) {
      backgroundColor = Colors.green.withOpacity(0.2);
      textColor = Colors.green;
    } else {
      backgroundColor = Theme.of(context).colorScheme.surface;
      textColor = Theme.of(context).colorScheme.onSurface;
    }

    return GestureDetector(
      onTap: () {
        ref.read(testNotifierProvider.notifier).goToQuestion(index);
        _toggleReviewPanel();
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrentQuestion
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isCurrentQuestion ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isMarked)
              Positioned(
                top: 2,
                right: 2,
                child: Icon(
                  Icons.bookmark,
                  color: Colors.orange,
                  size: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar(TestState testState) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Previous Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: testState.isFirstQuestion ? null : _previousQuestion,
                icon: const Icon(Icons.arrow_back),
                label: Text(l10n.previousQuestion),
              ),
            ),

            const SizedBox(width: 12),

            // Next Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: testState.isLastQuestion ? _showSubmitConfirmation : _nextQuestion,
                icon: Icon(testState.isLastQuestion ? Icons.send : Icons.arrow_forward),
                label: Text(testState.isLastQuestion ? 'Submit' : l10n.nextQuestion),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectAnswer(Question question, String answerId) {
    final testNotifier = ref.read(testNotifierProvider.notifier);
    final currentAnswer = ref.read(testNotifierProvider).getCurrentAnswer();
    final selectedAnswerIds = currentAnswer?.selectedAnswerIds ?? [];

    List<String> newSelectedIds;

    if (question.isRadio) {
      // Single selection
      newSelectedIds = [answerId];
    } else {
      // Multiple selection
      if (selectedAnswerIds.contains(answerId)) {
        newSelectedIds = selectedAnswerIds.where((id) => id != answerId).toList();
      } else {
        newSelectedIds = [...selectedAnswerIds, answerId];
      }
    }

    testNotifier.selectAnswer(question.id, newSelectedIds);
  }

  void _clearAnswer(int questionId) {
    ref.read(testNotifierProvider.notifier).clearAnswer(questionId);
  }

  void _toggleQuestionMark(int questionIndex) {
    ref.read(testNotifierProvider.notifier).toggleQuestionMark(questionIndex);
  }

  void _previousQuestion() {
    ref.read(testNotifierProvider.notifier).previousQuestion();
  }

  void _nextQuestion() {
    ref.read(testNotifierProvider.notifier).nextQuestion();
  }

  void _toggleReviewPanel() {
    setState(() {
      _showReviewPanel = !_showReviewPanel;
    });
  }

  void _showExitConfirmation() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Test?'),
        content: const Text('Are you sure you want to exit? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exitTest();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _showSubmitConfirmation() {
    final testState = ref.read(testNotifierProvider);
    final unansweredQuestions = testState.getUnansweredQuestions();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.submitTest),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.submitConfirmation),
            Text(l10n.cannotUndoSubmit),
            const SizedBox(height: 12),
            Text('Answered: ${testState.answeredQuestionsCount}/${testState.totalQuestions}'),
            if (unansweredQuestions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Unanswered questions: ${unansweredQuestions.length}',
                style: TextStyle(color: Colors.orange),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _submitTest();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTest({bool autoSubmit = false}) async {
    final testNotifier = ref.read(testNotifierProvider.notifier);
    final result = await testNotifier.submitTest();

    if (result != null && mounted) {
      _timer?.cancel();

      context.pushReplacement(
        AppRoutes.testResultPath(widget.testId, result.score),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit test. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _exitTest() {
    _timer?.cancel();
    ref.read(testNotifierProvider.notifier).clearCurrentTest();
    context.pop();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}