import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/question_model.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/test_provider.dart';
import '../widgets/circular_timer_widget.dart';
import '../widgets/enhanced_question_widget.dart';
import '../widgets/language_settings_bottom_sheet.dart';
import '../widgets/question_navigation_sheet.dart';

class TestTakingScreen extends ConsumerStatefulWidget {
  const TestTakingScreen({
    required this.testId,
    super.key,
    this.attemptId,
  });

  final int testId;
  final int? attemptId;

  @override
  ConsumerState<TestTakingScreen> createState() => _TestTakingScreenState();
}

class _TestTakingScreenState extends ConsumerState<TestTakingScreen> {
  PageController? _pageController;
  int _currentQuestionIndex = 0;
  late Map<String, List<String>> _answers;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _answers = {};
    _startTime = DateTime.now();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  // 🔥 NEW: Check if all questions are answered
  bool _areAllQuestionsAnswered(List<Question> questions) {
    for (final question in questions) {
      final answers = _answers[question.id];
      if (answers == null || answers.isEmpty) {
        return false;
      }
    }
    return true;
  }

  // 🔥 NEW: Get list of unanswered questions
  List<int> _getUnansweredQuestions(List<Question> questions) {
    final unanswered = <int>[];
    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final answers = _answers[question.id];
      if (answers == null || answers.isEmpty) {
        unanswered.add(i);
      }
    }
    return unanswered;
  }

  // 🔥 NEW: Jump to first unanswered question
  void _jumpToFirstUnansweredQuestion(List<Question> questions) {
    final unanswered = _getUnansweredQuestions(questions);
    if (unanswered.isNotEmpty) {
      _pageController?.animateToPage(
        unanswered.first,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final testState = ref.watch(testDetailProvider(widget.testId));

    return testState.when(
      data: (test) => Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context, test, theme, isDark, l10n),
            SliverFillRemaining(
              child: test.questions != null
                  ? PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentQuestionIndex = index;
                  });
                },
                itemCount: test.questions!.length,
                itemBuilder: (context, index) {
                  final question = test.questions![index];
                  return EnhancedQuestionWidget(
                    question: question,
                    questionNumber: index + 1,
                    totalQuestions: test.questions!.length,
                    selectedAnswers: _answers[question.id] ?? [],
                    onAnswerSelected: (answerId, isSelected) {
                      _handleAnswerSelection(question, answerId, isSelected);
                    },
                  );
                },
              )
                  : const Center(child: LoadingWidget()),
            ),
          ],
        ),

        // 🔥 UPDATED BOTTOM ACTION BAR with answer validation
        bottomNavigationBar: _buildBottomActionBar(context, test, theme, isDark, l10n),
      ),
      loading: () => Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.primary,
        body: const Center(child: LoadingWidget()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: CustomErrorWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(testDetailProvider(widget.testId)),
        ),
      ),
    );
  }

  // 🔥 SLIVER APP BAR WITH PROGRESS AND TIMER
  Widget _buildSliverAppBar(BuildContext context, dynamic test, ThemeData theme, bool isDark, AppLocalizations l10n) {
    final totalQuestions = test.questions?.length ?? 24;
    final progress = totalQuestions > 0 ? (_currentQuestionIndex + 1) / totalQuestions : 0.0;

    // Theme-aware colors
    final appBarBackground = isDark ? AppColors.surfaceDark : AppColors.primary;
    final appBarForeground = isDark ? AppColors.textPrimaryDark : Colors.white;
    final progressBackground = isDark
        ? AppColors.borderDark
        : Colors.white.withOpacity(0.3);
    final progressValue = isDark ? AppColors.primary : Colors.white;

    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: appBarBackground,
      foregroundColor: appBarForeground,
      leading: IconButton(
        onPressed: () => _showExitDialog(context, l10n),
        icon: Icon(Icons.close, color: appBarForeground),
      ),
      title: Text(
        test.displayTitle,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: appBarForeground,
        ),
      ),
      actions: [
        // Language Settings
        IconButton(
          onPressed: () => _showLanguageSettings(context),
          icon: Icon(Icons.language, color: appBarForeground),
          tooltip: l10n.test_languageSettings,
        ),

        // Question Navigation
        IconButton(
          onPressed: () => _showQuestionNavigation(context, test, l10n),
          icon: Icon(Icons.list, color: appBarForeground),
          tooltip: l10n.test_questionList,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [AppColors.surfaceDark, AppColors.cardDark]
                  : [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Row(
                children: [
                  // Progress Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          l10n.test_questionOf(_currentQuestionIndex + 1, totalQuestions),
                          style: TextStyle(
                            color: appBarForeground,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),

                        // Linear Progress Bar
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: progressBackground,
                          valueColor: AlwaysStoppedAnimation<Color>(progressValue),
                          minHeight: 6,
                        ),

                        const SizedBox(height: 4),
                        Text(
                          l10n.test_percentageComplete((progress * 100).round()),
                          style: TextStyle(
                            color: appBarForeground.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Circular Timer
                  CircularTimerWidget(
                    totalDuration: const Duration(minutes: 45),
                    onTimeUp: () => _submitTest(context, ref, l10n),
                    isDarkMode: isDark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 UPDATED BOTTOM ACTION BAR with enhanced answer validation display
  Widget _buildBottomActionBar(BuildContext context, dynamic test, ThemeData theme, bool isDark, AppLocalizations l10n) {
    final totalQuestions = test.questions?.length ?? 24;
    final isFirstQuestion = _currentQuestionIndex == 0;
    final isLastQuestion = _currentQuestionIndex >= totalQuestions - 1;
    final answeredCount = _answers.values.where((answers) => answers.isNotEmpty).length;
    final allAnswered = test.questions != null && _areAllQuestionsAnswered(test.questions!);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 8,
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (!isFirstQuestion) ...[
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: _previousQuestion,
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: Text(l10n.common_previous),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.primary.withOpacity(0.3)
                          ),
                          foregroundColor: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: isLastQuestion
                          ? () => _submitTest(context, ref, l10n)
                          : _nextQuestion,
                      icon: Icon(
                        isLastQuestion ? Icons.check : Icons.arrow_forward,
                        size: 18,
                      ),
                      label: Text(isLastQuestion ? l10n.common_submit : l10n.common_next),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLastQuestion && !allAnswered
                            ? AppColors.warning
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAnswerSelection(Question question, String answerId, bool isSelected) {
    setState(() {
      if (question.questionType == 'radio') {
        _answers[question.id] = isSelected ? [answerId] : [];
      } else {
        final currentAnswers = _answers[question.id] ?? [];
        if (isSelected) {
          if (!currentAnswers.contains(answerId)) {
            _answers[question.id] = [...currentAnswers, answerId];
          }
        } else {
          _answers[question.id] = currentAnswers.where((id) => id != answerId).toList();
        }
      }
    });
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _pageController?.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextQuestion() {
    _pageController?.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showLanguageSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LanguageSettingsBottomSheet(),
    );
  }

  void _showQuestionNavigation(BuildContext context, dynamic test, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuestionNavigationSheet(
        test: test,
        currentQuestionIndex: _currentQuestionIndex,
        answers: _answers,
        onQuestionTap: (index) {
          Navigator.pop(context);
          _pageController?.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }

  // 🔥 UPDATED: Submit test with complete answer validation
  Future<void> _submitTest(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final testState = ref.read(testDetailProvider(widget.testId));

    // Get questions from current test state
    final test = testState.value;
    if (test?.questions == null) {
      _showErrorSnackBar(context, l10n.test_testDataError, l10n);
      return;
    }

    final questions = test!.questions!;
    final allAnswered = _areAllQuestionsAnswered(questions);

    // 🔥 NEW: Check if all questions are answered
    if (!allAnswered) {
      final unansweredQuestions = _getUnansweredQuestions(questions);
      _showIncompleteAnswersDialog(context, l10n, unansweredQuestions, questions);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.test_submitConfirmationTitle,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.test_confirmSubmit,
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.test_allQuestionsAnsweredReady,
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => context.pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(l10n.common_submit),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(l10n.test_submittingTest),
                ],
              ),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              duration: const Duration(seconds: 10),
            ),
          );
        }

        final timeTaken = DateTime.now().difference(_startTime).inSeconds;
        final attemptId = await ref.read(testProvider.notifier).submitAttempt(
          attemptIdParam: widget.attemptId!,
          answers: _answers,
          timeTaken: timeTaken,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          context.go('/tests/result/$attemptId');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          _showErrorSnackBar(context, l10n.test_testSubmissionError, l10n);
        }
      }
    }
  }

  // 🔥 NEW: Show dialog when not all questions are answered
  void _showIncompleteAnswersDialog(BuildContext context, AppLocalizations l10n, List<int> unansweredQuestions, List<Question> allQuestions) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warning,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.test_incompleteAnswersTitle,
              style: TextStyle(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontSize: 18,
              ),
            ),
            IconButton(
              icon: Icon(Icons.close), // The 'X' icon
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.test_incompleteAnswersMessage(unansweredQuestions.length),
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.test_unansweredQuestions,
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    unansweredQuestions.take(5).map((index) => '${l10n.test_questionNumber(index + 1)}').join(', ') +
                        (unansweredQuestions.length > 5 ? l10n.test_andMore(unansweredQuestions.length - 5) : ''),
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _jumpToFirstUnansweredQuestion(allQuestions);
            },
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: Text(l10n.test_goToFirstUnanswered),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 NEW: Helper method to show error snackbar
  void _showErrorSnackBar(BuildContext context, String message, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: l10n.common_retry,
          textColor: Colors.white,
          onPressed: () => _submitTest(context, ref, l10n),
        ),
      ),
    );
  }

  Future<void> _showExitDialog(BuildContext context, AppLocalizations l10n) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.test_exitConfirmationTitle,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          l10n.test_confirmExit,
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.common_cancel,
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => context.pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.common_exit),
          ),
        ],
      ),
    );

    if (shouldExit == true && context.mounted) {
      context.go('/tests/${widget.testId}');
    }
  }
}