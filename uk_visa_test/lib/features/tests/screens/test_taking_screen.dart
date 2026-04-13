import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/services/interstitial_ad_service.dart';
import '../../../core/services/purchase_service.dart';
import '../../../data/models/question_model.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/test_provider.dart';
import '../widgets/circular_timer_widget.dart';
import '../widgets/enhanced_question_widget.dart';
import '../widgets/language_settings_bottom_sheet.dart';
import '../widgets/question_navigation_sheet.dart';
import '../widgets/time_up_dialog_widget.dart';

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
  late Map<String, bool> _answeredQuestions; // Track which questions have been answered
  late Map<String, bool> _correctAnswers; // Track correct/incorrect answers
  late DateTime _startTime;
  final InterstitialAdService _interstitialAdService = InterstitialAdService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _answers = {};
    _answeredQuestions = {};
    _correctAnswers = {};
    _startTime = DateTime.now();
    
    // Load interstitial ad for when test is completed (will check purchase status)
    _loadAdWithPurchaseCheck();
  }

  void _loadAdWithPurchaseCheck() {
    // Check if user has purchased ad removal
    final shouldShowAds = ref.read(shouldShowAdsProvider);
    _interstitialAdService.setShouldShowAds(shouldShowAds);
    
    _interstitialAdService.loadAd(
      onAdLoaded: () {
        print('🎯 Interstitial ad ready for test completion');
      },
      onAdFailedToLoad: (error) {
        print('⚠️ Failed to load interstitial ad: $error');
      },
    );
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _interstitialAdService.dispose();
    super.dispose();
  }

  // Check if test type is timed (exam) or not (chapter only)
  bool _isTimedTest(String testType) {
    return testType.toLowerCase() == 'exam' || testType.toLowerCase() == 'comprehensive';
  }

  bool _areAllQuestionsAnswered(List<Question> questions) {
    for (final question in questions) {
      final answers = _answers[question.id];
      if (answers == null || answers.isEmpty) {
        return false;
      }
    }
    return true;
  }

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final testState = ref.watch(testDetailProvider(widget.testId));

    return testState.when(
      data: (test) {
        final isTimedTest = _isTimedTest(test.testType);
        print('Test taking started - Type: ${test.testType}, Timed: $isTimedTest');

        return Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, test, theme, isDark, isTimedTest),
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
                    final isAnswered = _answeredQuestions[question.id] ?? false;
                    final isCorrect = _correctAnswers[question.id];
                    
                    // 🆕 Get correct answers for this question
                    final correctAnswers = question.answers
                        .where((answer) => answer.isCorrect == true)
                        .map((answer) => answer.answerId)
                        .toList();
                    
                    return EnhancedQuestionWidget(
                      question: question,
                      questionNumber: index + 1,
                      totalQuestions: test.questions!.length,
                      selectedAnswers: _answers[question.id] ?? [],
                      isAnswered: isAnswered,
                      isCorrect: isCorrect,
                      correctAnswers: correctAnswers, // 🆕 Pass correct answers
                      showCorrectAnswers: !isTimedTest && isAnswered, // 🔄 UPDATED: Only show in Practice mode after answering
                      allowAnswerChange: isTimedTest, // 🆕 EXAM MODE: Allow changing answers, PRACTICE MODE: Don't allow
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
          bottomNavigationBar: _buildBottomActionBar(context, test, theme, isDark, isTimedTest),
        );
      },
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

  Widget _buildSliverAppBar(BuildContext context, dynamic test, ThemeData theme, bool isDark, bool isTimedTest) {
    final totalQuestions = test.questions?.length ?? 24;
    final progress = totalQuestions > 0 ? (_currentQuestionIndex + 1) / totalQuestions : 0.0;

    // Theme-aware colors based on test type
    final appBarBackground = isDark
        ? AppColors.surfaceDark
        : (isTimedTest ? AppColors.warning : AppColors.info);
    final appBarForeground = isDark ? AppColors.textPrimaryDark : Colors.white;
    final progressBackground = isDark
        ? AppColors.borderDark
        : Colors.white.withValues(alpha: 0.3);
    final progressValue = isDark ? AppColors.primary : Colors.white;

    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: appBarBackground,
      foregroundColor: appBarForeground,
      leading: IconButton(
        onPressed: () => _showExitDialog(context, isTimedTest),
        icon: Icon(Icons.close, color: appBarForeground),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            test.displayTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: appBarForeground,
            ),
          ),
          Text(
            isTimedTest ? 'Timed Test' : 'Practice Mode',
            style: TextStyle(
              fontSize: 12,
              color: appBarForeground.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
      actions: [
        // Language Settings
        IconButton(
          onPressed: () => _showLanguageSettings(context),
          icon: Icon(Icons.language, color: appBarForeground),
          tooltip: 'Language Settings',
        ),

        // Question Navigation
        IconButton(
          onPressed: () => _showQuestionNavigation(context, test),
          icon: Icon(Icons.list, color: appBarForeground),
          tooltip: 'Question List',
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
                  : isTimedTest
                  ? [AppColors.warning, AppColors.warning.withValues(alpha: 0.8)]
                  : [AppColors.info, AppColors.info.withValues(alpha: 0.8)],
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
                          'Question ${_currentQuestionIndex + 1} of $totalQuestions',
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
                          '${(progress * 100).round()}% complete',
                          style: TextStyle(
                            color: appBarForeground.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Conditional Timer based on test type
                  if (isTimedTest) ...[
                    CircularTimerWidget(
                      totalDuration: test.effectiveTimeLimit,
                      onTimeUp: () => _handleTimeUp(context, ref),
                      isDarkMode: isDark,
                    ),
                  ] else ...[
                    // Practice mode indicator
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: appBarForeground.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: appBarForeground.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.all_inclusive,
                            color: appBarForeground,
                            size: 30,
                          )
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, dynamic test, ThemeData theme, bool isDark, bool isTimedTest) {
    final totalQuestions = test.questions?.length ?? 24;
    final isFirstQuestion = _currentQuestionIndex == 0;
    final isLastQuestion = _currentQuestionIndex >= totalQuestions - 1;
    final allAnswered = test.questions != null && _areAllQuestionsAnswered(test.questions!);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 8,
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
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
                        label: const Text('Previous'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.primary.withValues(alpha: 0.3)
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
                          ? () => _submitTest(context, ref, isTimedTest)
                          : _nextQuestion,
                      icon: Icon(
                        isLastQuestion ? Icons.check : Icons.arrow_forward,
                        size: 18,
                      ),
                      label: Text(isLastQuestion ? 'Submit' : 'Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isTimedTest
                            ? (isLastQuestion && !allAnswered ? AppColors.warning : AppColors.warning)
                            : (isLastQuestion && !allAnswered ? AppColors.warning : AppColors.info),
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
        // 🔥 For radio questions: always set the new selection (replacing any previous selection)
        if (isSelected) {
          _answers[question.id] = [answerId]; // Replace with new selection
          _answeredQuestions[question.id] = true;
          
          // 🆕 UPDATED: Only check correctness in Practice mode (when showCorrectAnswers is enabled)
          final testState = ref.read(testDetailProvider(widget.testId));
          final isTimedTest = testState.value != null ? _isTimedTest(testState.value!.testType) : false;
          if (!isTimedTest) {
            // Practice mode: check correctness immediately
            _correctAnswers[question.id] = _isAnswerCorrect(question, _answers[question.id]!);
          }
        }
        // Note: For radio buttons, we don't allow deselecting (isSelected will always be true when called)
      } else {
        // Handle checkbox questions - allow multiple selections
        final currentAnswers = _answers[question.id] ?? [];
        if (isSelected) {
          if (!currentAnswers.contains(answerId)) {
            _answers[question.id] = [...currentAnswers, answerId];
          }
        } else {
          _answers[question.id] = currentAnswers.where((id) => id != answerId).toList();
        }

        // 🆕 Get the required number of answers from the question model
        final requiredCount = question.requiredAnswers;
        final selectedAnswers = _answers[question.id] ?? [];
        
        // 🆕 UPDATED: Only check correctness in Practice mode
        final testState = ref.read(testDetailProvider(widget.testId));
        final isTimedTest = testState.value != null ? _isTimedTest(testState.value!.testType) : false;
        
        // If user has selected the required number of answers, check correctness in Practice mode
        if (selectedAnswers.length == requiredCount) {
          // Mark as answered when required count is reached
          _answeredQuestions[question.id] = true;
          
          // Only check correctness in Practice mode
          if (!isTimedTest) {
            final correctAnswers = question.answers
                .where((answer) => answer.isCorrect == true)
                .map((answer) => answer.answerId)
                .toSet();
            
            final selectedAnswersSet = selectedAnswers.toSet();
            
            // Check if ANY selected answer is incorrect
            final hasIncorrectAnswer = selectedAnswersSet.any((answerId) {
              return !correctAnswers.contains(answerId);
            });
            
            // If any answer is incorrect, mark the whole question as wrong
            if (hasIncorrectAnswer) {
              _correctAnswers[question.id] = false;
            } else {
              // All selected answers are correct, check if we have all correct answers
              final hasAllCorrectAnswers = correctAnswers.length == selectedAnswersSet.length && 
                                         correctAnswers.containsAll(selectedAnswersSet);
              _correctAnswers[question.id] = hasAllCorrectAnswers;
            }
          }
        } else {
          // Not enough answers selected yet
          _answeredQuestions[question.id] = false;
          _correctAnswers.remove(question.id);
        }
      }
    });
  }

  // Helper method to check if the selected answers are correct
  bool _isAnswerCorrect(Question question, List<String> selectedAnswerIds) {
    final correctAnswers = question.answers
        .where((answer) => answer.isCorrect == true)
        .map((answer) => answer.answerId)
        .toSet();
    
    final selectedAnswers = selectedAnswerIds.toSet();
    
    // For both radio and checkbox questions, all correct answers must be selected
    // and no incorrect answers should be selected
    return correctAnswers.length == selectedAnswers.length && 
           correctAnswers.containsAll(selectedAnswers);
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

  void _showQuestionNavigation(BuildContext context, dynamic test) {
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

  // Handle time up for timed tests (exam)
  void _handleTimeUp(BuildContext context, WidgetRef ref) {
    print('Time is up! Auto-submitting exam...');
    context.showTimeUpDialog(
      onSubmit: () {
        Navigator.of(context).pop(); // Close dialog
        _submitTestDirectly(context, ref);
      },
    );
  }

  // Direct submit without validation (for time up)
  Future<void> _submitTestDirectly(BuildContext context, WidgetRef ref) async {
    try {
      final timeTaken = DateTime.now().difference(_startTime).inSeconds;
      final attemptId = await ref.read(testProvider.notifier).submitAttempt(
        attemptIdParam: widget.attemptId!,
        answers: _answers,
        timeTaken: timeTaken,
      );

      if (context.mounted) {
        context.go('/tests/result/$attemptId');
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to submit test. Please try again.');
      }
    }
  }

  Future<void> _submitTest(BuildContext context, WidgetRef ref, bool isTimedTest) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final testState = ref.read(testDetailProvider(widget.testId));

    final test = testState.value;
    if (test?.questions == null) {
      _showErrorSnackBar(context, 'Test data not available. Please try again.');
      return;
    }

    final questions = test!.questions!;
    final allAnswered = _areAllQuestionsAnswered(questions);

    // Different validation for Practice vs Exam tests
    if (!isTimedTest && !allAnswered) {
      // For practice tests, require all questions to be answered
      final unansweredQuestions = _getUnansweredQuestions(questions);
      _showIncompleteAnswersDialog(context, unansweredQuestions, questions);
      return;
    }

    // NEW LOGIC: For Exam tests, require ALL questions to be answered before allowing result/review access
    if (isTimedTest && !allAnswered) {
      final unansweredQuestions = _getUnansweredQuestions(questions);
      _showIncompleteExamAnswersDialog(context, unansweredQuestions, questions);
      return;
    }

    // For exam tests (timed tests), all questions must be answered before allowing submission
    String confirmationMessage;

    if (!isTimedTest) {
      confirmationMessage = 'Are you sure you want to submit this test?';
    } else {
      // For exam mode, since we already validated all answers are provided
      confirmationMessage = 'Are you sure you want to submit this test?';
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isTimedTest ? 'Submit Exam' : 'Submit Practice',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              confirmationMessage,
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (allAnswered ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: (allAnswered ? AppColors.success : AppColors.warning).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    allAnswered ? Icons.check_circle : Icons.warning_amber,
                    color: allAnswered ? AppColors.success : AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      allAnswered
                          ? 'All questions answered. Ready to submit!'
                          : '${_answers.values.where((answers) => answers.isNotEmpty).length} of ${questions.length} questions answered',
                      style: TextStyle(
                        color: allAnswered ? AppColors.success : AppColors.warning,
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => context.pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isTimedTest ? AppColors.warning : AppColors.info,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // 🚫 TEMPORARILY DISABLED: Video ad before submitting
      // For Exam mode, show video ad before submitting
      // if (isTimedTest) {
      //   try {
      //     await _showVideoAdBeforeSubmit(context, ref, l10n);
      //   } catch (e) {
      //     print('🎯 Error showing video ad: $e');
      //     // Continue with submission even if ad fails
      //   }
      // }
      
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
                  const Text('Submitting test...'),
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
          
          // Show interstitial ad before navigating to result screen
          _interstitialAdService.showAd(
            onAdDismissed: () {
              // Ad was dismissed, navigate to result screen
              if (context.mounted) {
                context.go('/tests/result/$attemptId');
              }
            },
            onAdFailedToShow: () {
              // Ad failed to show, navigate to result screen anyway
              if (context.mounted) {
                context.go('/tests/result/$attemptId');
              }
            },
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          _showErrorSnackBar(context, 'Failed to submit test. Please try again.');
        }
      }
    }
  }

  // 🆕 Show test summary dialog instead of navigating to result screen
  void _showTestSummaryDialog(BuildContext context, WidgetRef ref, dynamic test, String attemptId) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isTimedTest = _isTimedTest(test.testType);
    
    // Calculate results
    final totalQuestions = test.questions!.length;
    final correctCount = _correctAnswers.values.where((isCorrect) => isCorrect).length;
    final incorrectCount = _correctAnswers.values.where((isCorrect) => !isCorrect).length;
    final unansweredCount = totalQuestions - _correctAnswers.length;
    
    // 🔥 FIX: Calculate percentage based on TOTAL questions, not just answered ones
    // This matches the server-side calculation for consistency
    final percentage = totalQuestions > 0 ? (correctCount / totalQuestions * 100) : 0.0;
    final timeTaken = DateTime.now().difference(_startTime);
    final allAnswered = _areAllQuestionsAnswered(test.questions!);
    
    final isPassed = percentage >= 75.0; // UK citizenship test requires 75%
    
    print('📊 Test Summary Calculation:');
    print('   Total Questions: $totalQuestions');
    print('   Correct Answers: $correctCount');
    print('   Incorrect Answers: $incorrectCount');
    print('   Unanswered: $unansweredCount');
    print('   Percentage: ${percentage.toStringAsFixed(1)}%');
    print('   Passed: $isPassed');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isPassed ? Icons.celebration : Icons.info_outline,
              color: isPassed ? AppColors.success : AppColors.warning,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isPassed ? 'Test Completed!' : 'Test Completed',
                style: TextStyle(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Overall result banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isPassed ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isPassed ? AppColors.success : AppColors.warning).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '${percentage.round()}%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isPassed ? AppColors.success : AppColors.warning,
                    ),
                  ),
                  Text(
                    isPassed ? 'PASSED' : 'NEEDS IMPROVEMENT',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isPassed ? AppColors.success : AppColors.warning,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Statistics - 3 cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.check_circle,
                    label: 'Correct',
                    value: correctCount.toString(),
                    color: AppColors.success,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.cancel,
                    label: 'Incorrect',
                    value: incorrectCount.toString(),
                    color: AppColors.error,
                    isDark: isDark,
                  ),
                ),
                if (unansweredCount > 0) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.help_outline,
                      label: 'Unanswered',
                      value: unansweredCount.toString(),
                      color: AppColors.warning,
                      isDark: isDark,
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Time taken
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.surfaceDark : Colors.grey[50]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Time: ${_formatDuration(timeTaken)}',
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/tests/detail/${widget.testId}');
            },
            child: Text(
              'Back to Test',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
          // NEW LOGIC: Only allow access to results/review if:
          // - Practice mode (always allowed)
          // - Exam mode AND all questions answered
          if (!isTimedTest || (isTimedTest && allAnswered))
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/tests/result/$attemptId');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Review Answers'),
            )
          else
            // Show disabled button with explanation for incomplete exams
            Tooltip(
              message: 'Complete all questions to access results',
              child: ElevatedButton(
                onPressed: null, // Disabled
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white60,
                ),
                child: const Text('Review Answers'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  void _showIncompleteAnswersDialog(BuildContext context, List<int> unansweredQuestions, List<Question> allQuestions) {
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
            Expanded(
              child: Text(
                'Incomplete Answers',
                style: TextStyle(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontSize: 18,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have ${unansweredQuestions.length} unanswered question${unansweredQuestions.length > 1 ? 's' : ''}',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Unanswered Questions',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    unansweredQuestions.take(5).map((index) => 'Q${index + 1}').join(', ') +
                        (unansweredQuestions.length > 5 ? ' and ${unansweredQuestions.length - 5} more...' : ''),
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
            label: const Text('Go to first unanswered'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // NEW: Show exam incomplete answers dialog (different from practice)
  void _showIncompleteExamAnswersDialog(BuildContext context, List<int> unansweredQuestions, List<Question> allQuestions) {
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
              Icons.error_outline,
              color: AppColors.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Complete All Questions Required',
                style: TextStyle(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontSize: 18,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For exam mode, you must answer ALL questions before you can view results or review answers.',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unanswered Questions (${unansweredQuestions.length})',
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    unansweredQuestions.take(5).map((index) => 'Q${index + 1}').join(', ') +
                        (unansweredQuestions.length > 5 ? ' and ${unansweredQuestions.length - 5} more...' : ''),
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
            label: const Text('Continue Exam'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => _submitTest(context, ref, _isTimedTest(ref.read(testDetailProvider(widget.testId)).value?.testType ?? 'chapter')),
        ),
      ),
    );
  }

  Future<void> _showExitDialog(BuildContext context, bool isTimedTest) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Exit Test?',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to exit? Your progress will be lost.',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            if (isTimedTest) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Exiting a timed test will lose your progress',
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => context.pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (shouldExit == true && context.mounted) {
      context.go('/tests/detail/${widget.testId}');
    }
  }
}